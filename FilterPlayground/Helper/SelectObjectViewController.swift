//
//  SelectObjectViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.12.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

protocol SelectObjectViewControllerPresentable {
    var title: String { get }
    var subtitle: String? { get }
    var image: UIImage? { get }
    var interactionEnabled: Bool { get }
}

class SelectObjectController: UINavigationController, UIPopoverPresentationControllerDelegate {

    public var enforcePresentationStyle: Bool = false

    init(title: String? = nil, objects: [[SelectObjectViewControllerPresentable]], style: UITableViewStyle = .plain, callback: @escaping (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void) {
        let rootViewController = SelectObjectViewController(title: title, objects: objects, style: style, callback: callback)
        super.init(rootViewController: rootViewController)
        popoverPresentationController?.delegate = self
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Mark: UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if enforcePresentationStyle {
            return .none
        }
        return controller.adaptivePresentationStyle(for: traitCollection)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            (self.viewControllers.first as! SelectObjectViewController).configureCancelButton(arrowDirection: self.popoverPresentationController?.arrowDirection ?? .unknown, animated: true)
        }
    }
}

class SelectObjectViewController: UITableViewController {

    fileprivate var objects: [[SelectObjectViewControllerPresentable]]
    fileprivate var callback: (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void

    private let cellReuseIdentifier = "reuseIdentifier"

    init(title: String? = nil, objects: [[SelectObjectViewControllerPresentable]], style: UITableViewStyle = .plain, callback: @escaping (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void) {
        self.objects = objects
        self.callback = callback
        super.init(style: style)
        self.title = title
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.layoutIfNeeded()
        preferredContentSize = tableView.contentSize
        configureCancelButton(arrowDirection: navigationController?.popoverPresentationController?.arrowDirection ?? .unknown)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func configureCancelButton(arrowDirection: UIPopoverArrowDirection, animated: Bool = false) {
        if arrowDirection == .unknown ||
            traitCollection.userInterfaceIdiom == .phone {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            navigationItem.setRightBarButton(cancelButton, animated: animated)
        } else {
            navigationItem.setRightBarButton(nil, animated: animated)
        }
    }

    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return objects.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) ?? UITableViewCell(style: .subtitle,
                                                                                                         reuseIdentifier: cellReuseIdentifier)

        let object = objects[indexPath.section][indexPath.row]
        cell.textLabel?.text = object.title
        cell.detailTextLabel?.text = object.subtitle
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.image = object.image
        cell.isUserInteractionEnabled = object.interactionEnabled
        cell.accessoryType = object.interactionEnabled ? .disclosureIndicator : .none

        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = objects[indexPath.section][indexPath.row]
        callback(object, self)
        dismiss(animated: true, completion: nil)
    }
}
