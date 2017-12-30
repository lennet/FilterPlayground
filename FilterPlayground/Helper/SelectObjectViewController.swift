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

class SelectObjectViewController: UITableViewController {

    fileprivate var objects: [[SelectObjectViewControllerPresentable]]
    fileprivate var callback: (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void

    private let cellReuseIdentifier = "reuseIdentifier"

    init(objects: [[SelectObjectViewControllerPresentable]], style: UITableViewStyle = .plain, callback: @escaping (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void) {
        self.objects = objects
        self.callback = callback
        super.init(style: style)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.layoutIfNeeded()
        preferredContentSize = tableView.contentSize
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
