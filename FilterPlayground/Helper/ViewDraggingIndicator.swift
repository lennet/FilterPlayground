//
//  ViewDraggingIndicator.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ViewDraggingIndicator: UIView {

    @IBOutlet var indicator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        indicator.layer.cornerRadius = 4
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        indicator.isHidden = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        indicator.isHidden = true
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        indicator.isHidden = true
    }
}
