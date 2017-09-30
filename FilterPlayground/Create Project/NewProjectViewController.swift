//
//  NewProjectViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class NewProjectViewController: UITableViewController {

    var didSelectType: ((KernelType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // todo add cancel button
        // self.navigationItem.rightBarButtonItem =
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Table view delegate

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type: KernelType
        switch indexPath.row {
        case 1:
            type = .coreimagewarp
            break
        case 2:
            type = .coreimagecolor
            break
        case 3:
            type = .coreimageblend
            break
        default:
            type = .coreimage
            break
        }
        didSelectType?(type)
    }
}
