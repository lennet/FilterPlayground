//
//  SelectDataBindingViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

// TODo refactor SelectDataBindingViewController & SelectTypeViewControler
class SelectDataBindingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var didSelectBinding: ((DataBinding) -> Void)?

    var supportedBindings: [DataBinding] = []

    @IBAction func cancel(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return supportedBindings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        cell.textLabel?.text = "\(supportedBindings[indexPath.row])"
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.didSelectBinding?(self.supportedBindings[indexPath.row])
        }
    }
}
