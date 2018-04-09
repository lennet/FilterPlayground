//
//  NewProjectViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

extension KernelType: SelectObjectViewControllerPresentable {
    var title: String {
        return String(describing: kernelClass)
    }

    var subtitle: String? {
        return "TODO"
    }

    var image: UIImage? {
        // TODO:
        return nil
    }

    var interactionEnabled: Bool {
        return true
    }
}

class NewProjectViewController: UITableViewController {
    var didSelectType: ((KernelType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        var objects: [[KernelType]] = [[.coreimage, .coreimagewarp, .coreimagecolor, .coreimageblend]]
        if FeatureGate.isEnabled(feature: .metal) {
            objects.append([.metal])
        }
        let tableView = SelectObjectTableView(frame: view.bounds, objects: objects, callback: { kernelType, _ in
            self.didSelectType?(kernelType as! KernelType)
        })
        if FeatureGate.isEnabled(feature: .metal) {
            tableView.sectionTitles = ["CoreImage Shading Language", "Metal Shading Language"]
        }
        self.tableView = tableView
    }
}
