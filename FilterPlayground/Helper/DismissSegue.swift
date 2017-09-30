//
//  DismissSegue.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 17.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {

    override func perform() {
        source.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
