//
//  SelectTypeViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SelectTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var didSelectType: ((KernelAttributeType) -> Void)?

    fileprivate let attributes: [KernelAttributeType] = KernelAttributeType.all

    @IBAction func cancel(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return attributes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        cell.textLabel?.text = "\(attributes[indexPath.row])"
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectType?(attributes[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}
