//
//  AttributesViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class AttributesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    enum AttributesViewControllerSection: Int {
        case outputSize
        case inputImages
        case arguments

        var title: String {
            switch self {
            case .outputSize:
                return "Extent"
            case .inputImages:
                return "Input images"
            case .arguments:
                return "Arguments"
            }
        }

        static var count: Int {
            return 3
        }
    }

    @IBOutlet var tableView: UITableView!

    var shouldReloadOnUpdate = true
    var shadingLanguage: ShadingLanguage = .coreimage
    var supportedArguments: [KernelArgumentType] = []

    var inputImages: [KernelInputImage] = [] {
        didSet {
            tableView.reloadSections(IndexSet(integer: AttributesViewControllerSection.inputImages.rawValue), with: .none)
        }
    }

    var arguments: [KernelArgument] = [] {
        didSet {
            if shouldReloadOnUpdate {
                self.tableView.reloadData()
            }
            shouldReloadOnUpdate = true
        }
    }

    var filtredArguments: [KernelArgument] {
        return arguments.filter({ (argument) -> Bool in
            switch (argument.access, argument.origin) {
            case (_, .other),
                 (.write, _):
                return false
            default:
                return true
            }
        })
    }

    var extentSettings: KernelOutputSizeSetting = .none {
        didSet {
            self.tableView.reloadData()
        }
    }

    var outputSize: KernelOutputSize = .inherit
    var inheritSize: CGRect = .zero {
        didSet {
            loadViewIfNeeded()
            self.tableView.reloadData()
        }
    }

    var didUpdateAttributes: ((Bool) -> Void)?
    var didUpdatedImage: ((KernelInputImage) -> Void)?
    var didUpdatedOutputSize: ((KernelOutputSize) -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }

    // Mark: Tableview data source

    func numberOfSections(in _: UITableView) -> Int {
        return AttributesViewControllerSection.count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard numberOfRows(in: section) > 0 else { return nil }
        return AttributesViewControllerSection(rawValue: section)?.title
    }

    // created extra method to avoid call cycle
    func numberOfRows(in section: Int) -> Int {
        switch AttributesViewControllerSection(rawValue: section)! {
        case .arguments:
            return filtredArguments.count + 1
        case .inputImages:
            return inputImages.count
        case .outputSize:
            if case .none = extentSettings {
                return 0
            }
            return 1
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        return numberOfRows(in: sectionIndex)
    }

    func didUpdateAttribute(cell: UITableViewCell, attribute: KernelArgument) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if indexPath.row < filtredArguments.count {
            let oldAttribute = arguments[Int(attribute.index)]
            shouldReloadOnUpdate = false
            arguments[Int(attribute.index)] = attribute
            // we only need to rerun if values have changed.
            // we compare name and attributes because comparing values can be expensive for images
            let updatedType = oldAttribute.type != attribute.type
            didUpdateAttributes?(oldAttribute.name == attribute.name && !updatedType)
            if attribute.type == .sample || updatedType {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        } else {
            var newAttribute = attribute
            newAttribute.index = arguments.count
            if case .metal = shadingLanguage {
                let isTexture = newAttribute.type.rawValue == KernelArgumentType.texture2d.rawValue
                newAttribute.origin = isTexture ? .texture : .buffer
            }
            arguments.append(newAttribute)
            tableView.reloadData()
            didUpdateAttributes?(false)
        }
    }

    func didUpatedInputImage(value: KernelInputImage) {
        inputImages[value.index] = value
        didUpdatedImage?(value)
    }

    func prepareKernelAttributeCell(tableView: UITableView, indexPath: IndexPath) -> KernelAttributeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KernelAttributeTableViewCellIdentifier", for: indexPath) as! KernelAttributeTableViewCell
        if indexPath.row < filtredArguments.count {
            cell.attribute = filtredArguments[indexPath.row]
        }

        cell.updateCallBack = { [weak self] cell, argument in
            self?.didUpdateAttribute(cell: cell, attribute: argument)
        }
        cell.supportedTypes = supportedArguments
        return cell
    }

    func prepareInputImageCell(tableView: UITableView, indexPath: IndexPath) -> InputImageTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InputImageTableViewCell.identifier, for: indexPath) as! InputImageTableViewCell
        cell.set(imageValue: inputImages[indexPath.row])
        cell.updatedImageCallBack = { [weak self] image in
            self?.didUpatedInputImage(value: image)
        }
        return cell
    }

    func prepareOutputSizeCell(tableView: UITableView, indexPath: IndexPath) -> KernelOutputSizeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KernelOutputSizeTableViewCell.identifier, for: indexPath) as! KernelOutputSizeTableViewCell
        cell.outputSize = outputSize
        cell.inheritSize = inheritSize
        cell.canSetPosition = extentSettings == .sizeAndPosition
        cell.didUpdatedOutputSize = { [weak self] outputSize in
            self?.didUpdatedOutputSize?(outputSize)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch AttributesViewControllerSection(rawValue: indexPath.section)! {
        case .arguments:
            return prepareKernelAttributeCell(tableView: tableView, indexPath: indexPath)
        case .inputImages:
            return prepareInputImageCell(tableView: tableView, indexPath: indexPath)
        case .outputSize:
            return prepareOutputSizeCell(tableView: tableView, indexPath: indexPath)
        }
    }

    // MARK: - Delegate

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch AttributesViewControllerSection(rawValue: indexPath.section)! {
        case .arguments:
            return indexPath.row < arguments.count
        case .inputImages:
            return false
        case .outputSize:
            return false
        }
    }

    func tableView(_: UITableView, editActionsForRowAt _: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "remove", handler: deleteAttribute)]
    }

    func deleteAttribute(action _: UITableViewRowAction, for indexPath: IndexPath) {
        if let cell = tableView(tableView, cellForRowAt: indexPath) as? KernelAttributeTableViewCell {
            cell.updateCallBack = nil
        }
        arguments.remove(at: indexPath.row)
        tableView.reloadData()
        didUpdateAttributes?(false)
    }

    @objc func themeChanged(notification _: Notification?) {
        view.backgroundColor = ThemeManager.shared.currentTheme.attributesBackground
        tableView.separatorColor = ThemeManager.shared.currentTheme.attributesSeparatorColor
    }
}
