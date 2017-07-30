//
//  AttributesViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class AttributesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    var kernelDescriptor = KernelDescriptor(name: "testFunc", type: .warp,attributes: [])
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    var didUpdateDescriptor: ((KernelDescriptor, Bool) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        kernelDescriptor.name = sender.text ?? ""
        didUpdateDescriptor?(kernelDescriptor, false)
    }
    
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            kernelDescriptor.type = .warp
            break
        case 1:
            kernelDescriptor.type = .color
            break
        default:
            break
        }
        didUpdateDescriptor?(kernelDescriptor, false)
    }
    
    func didUpdateAttribute(cell: UITableViewCell, attribute: KernelAttribute) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        if indexPath.row < kernelDescriptor.attributes.count {
            kernelDescriptor.attributes[indexPath.row] = attribute
        } else {
            kernelDescriptor.attributes.append(attribute)
            tableView.insertRows(at: [IndexPath(row: indexPath.row+1, section: 0)], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kernelDescriptor.attributes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AtributeCellIdentifier", for: indexPath) as! KernelAttributeTableViewCell
        if indexPath.row < kernelDescriptor.attributes.count {
            cell.attribute = kernelDescriptor.attributes[indexPath.row]
        } else {
            cell.attribute = KernelAttribute(name: "", type: .none, value: .none)
        }
        cell.peromSegueCallBack = performSegue
        cell.updateCallBack = didUpdateAttribute
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let typePicker = segue.destination as? SelectTypeViewController else {
            return
        }
        guard let cell = sender as? KernelAttributeTableViewCell else {
            return
        }
        
        typePicker.popoverPresentationController?.sourceView = cell
        if let indexPath = tableView.indexPath(for: cell) {
            typePicker.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
        }
        
        typePicker.didSelectType = { type in
            cell.attribute?.type = type
        }
    }
}
