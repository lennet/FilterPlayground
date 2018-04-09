//
//  SelectTemplateTableViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

typealias Template = URL

extension Template: SelectObjectViewControllerPresentable {
    var title: String {
        return lastPathComponent
    }

    var subtitle: String? {
        return nil
    }

    var image: UIImage? {
        return nil
    }

    var interactionEnabled: Bool {
        return true
    }
}

class SelectTemplateTableViewController: UITableViewController {
    var didSelectTemplate: ((Template) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = SelectObjectTableView(frame: view.bounds, objects: [TemplatesManager.getURLs()], callback: { kernelType, _ in
            self.didSelectTemplate?(kernelType as! Template)
        })
    }
}
