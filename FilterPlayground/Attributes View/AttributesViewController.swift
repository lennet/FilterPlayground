//
//  AttributesViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class AttributesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var shouldUpdateOnReload = true
    var attributes: [KernelAttribute] = [] {
        didSet {
            if shouldUpdateOnReload {
                self.tableView.reloadData()
            }
            shouldUpdateOnReload = true
        }
    }
    var didUpdateAttributes: ((Bool)->())?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }

    // Mark: Tableview data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributes.count + 1
    }
    
    func didUpdateAttribute(cell: UITableViewCell, attribute: KernelAttribute) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if indexPath.row < attributes.count {
            let oldAttribute = attributes[indexPath.row]
            shouldUpdateOnReload = false
            attributes[indexPath.row] = attribute
            // we only need to rerun if values have changed.
            // we compare name and attributes because comparing values can be expensive for images
            didUpdateAttributes?(oldAttribute.name == attribute.name && oldAttribute.type == attribute.type)
        } else {
            attributes.append(attribute)
            tableView.reloadData()
            didUpdateAttributes?(false)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KernelAttributeTableViewCellIdentifier", for: indexPath) as! KernelAttributeTableViewCell
        if indexPath.row < attributes.count {
            cell.attribute = attributes[indexPath.row]
        } else {
            cell.attribute = nil
        }
        
        cell.updateCallBack = didUpdateAttribute
        return cell
    }
    
    // MARK: - Delegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < attributes.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "remove", handler: deleteAttribute)]
    }
    
    func deleteAttribute(action: UITableViewRowAction, for indexPath: IndexPath) {
        attributes.remove(at: indexPath.row)
        tableView.reloadData()
        didUpdateAttributes?(false)
    }
    
    @objc func themeChanged(notification: Notification?) {
        view.backgroundColor = ThemeManager.shared.currentTheme.attributesBackground
        tableView.separatorColor = ThemeManager.shared.currentTheme.attributesSeparatorColor
    }
    
}
