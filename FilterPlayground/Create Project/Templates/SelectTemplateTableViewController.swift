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
    var didSelectTemplate: ((URL)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // todo check for different types
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identiifer", for: indexPath)
        let document = Document(fileURL: templates[indexPath.row])
        cell.textLabel?.text = document.title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTemplate?(templates[indexPath.row])
    }

}
