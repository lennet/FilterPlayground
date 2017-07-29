//
//  AttributesViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class AttributesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var attributes: [KernelAttribute] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateAttribute(cell: UITableViewCell, attribute: KernelAttribute) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        if indexPath.row < attributes.count {
            attributes[indexPath.row] = attribute
        } else {
            attributes.append(attribute)
            tableView.insertRows(at: [IndexPath(row: indexPath.row+1, section: 0)], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AtributeCellIdentifier", for: indexPath) as! KernelAttributeTableViewCell
        if indexPath.row < attributes.count {
            cell.attribute = attributes[indexPath.row]
        } else {
            cell.attribute = .none
        }
        
        cell.updateCallBack = didUpdateAttribute
        
        return cell
    }
    
}
