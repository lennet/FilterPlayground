//
//  SelectObjectTableView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 09.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class SelectObjectTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var objects: [[SelectObjectViewControllerPresentable]]! {
        didSet {
            if oldValue != nil {
                reloadData()
            }
        }
    }

    var sectionTitles: [String]?

    fileprivate var callback: ((SelectObjectViewControllerPresentable, SelectObjectTableView) -> Void)!

    private let cellReuseIdentifier = "reuseIdentifier"

    init(frame: CGRect, objects: [[SelectObjectViewControllerPresentable]], style: UITableViewStyle = .plain, callback: @escaping (SelectObjectViewControllerPresentable, SelectObjectTableView) -> Void) {
        self.objects = objects
        self.callback = callback

        super.init(frame: frame, style: style)

        delegate = self
        dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Table view data source

    func numberOfSections(in _: UITableView) -> Int {
        return objects.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects[section].count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let titles = sectionTitles,
            titles.count > section else { return nil }
        return titles[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = objects[indexPath.section][indexPath.row]
        callback(object, self)
    }
}
