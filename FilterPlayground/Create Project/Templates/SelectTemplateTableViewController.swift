//
//  SelectTemplateTableViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SelectTemplateTableViewController: UITableViewController {
    let templates = TemplatesManager.getURLs()
    var didSelectTemplate: ((URL) -> Void)?

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        // TODO: check for different types
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return templates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identiifer", for: indexPath)
        let document = Project(fileURL: templates[indexPath.row])
        cell.textLabel?.text = document.title
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTemplate?(templates[indexPath.row])
    }
}
