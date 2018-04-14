//
//  ViewDraggingIndicator.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class DraggingIndicatorView: UIView {
    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        backgroundColor = .blue
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ViewDraggingIndicator: UIView {
    @IBOutlet var indicator: DraggingIndicatorView!
    var alwaysShowIndicator = false {
        didSet {
            if alwaysShowIndicator {
                indicator.isHidden = false
            }
        }
    }

    var expandIndicator = false {
        didSet {
            updateConstraints()
            if expandIndicator {
                indicator.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else {
                indicator.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            }
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        indicator.constraint(for: .width)?.constant = expandIndicator ? 40 : 80
        constraint(for: .centerX)?.constant = expandIndicator ? -20 : 0
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        indicator.layer.cornerRadius = 4
        indicator.clipsToBounds = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        indicator.isHidden = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        indicator.isHidden = true || !alwaysShowIndicator
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        indicator.isHidden = true || !alwaysShowIndicator
    }
}
