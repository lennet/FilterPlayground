//
//  InputImageTableViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 17.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class InputImageTableViewCell: UITableViewCell {
    static let identifier = "InputImageTableViewCellIdentifier"

    @IBOutlet var inputImageView: CustomImageView!
    @IBOutlet var inputImageViewHeightConstraint: NSLayoutConstraint!

    var value: KernelInputImage? {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    var updatedImageCallBack: ((KernelInputImage) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        inputImageView.didSelectImage = didSelectImage
    }

    override func updateConstraints() {
        super.updateConstraints()
        if let imageSize = inputImageView.image?.size {
            let ratio = bounds.width / imageSize.width
            inputImageViewHeightConstraint.constant = (imageSize.height * ratio) - 8.0
        } else {
            inputImageViewHeightConstraint.constant = bounds.width - 8.0
        }
    }

    func set(imageValue: KernelInputImage) {
        inputImageView.image = imageValue.image
        if imageValue.shouldHighlightIfMissing {
            highlightMissingImage()
        }
        value = imageValue
    }

    func highlightMissingImage() {
        inputImageView.layer.borderColor = UIColor.red.withAlphaComponent(0.7).cgColor
        inputImageView.layer.borderWidth = 2
    }

    func didSelectImage(customImageView: CustomImageView) {
        guard var value = value else { return }
        remsetBorder()
        value.image = customImageView.image
        setNeedsUpdateConstraints()
        layoutIfNeeded()
        updatedImageCallBack?(value)
    }

    func remsetBorder() {
        inputImageView.layer.borderColor = UIColor.clear.cgColor
        inputImageView.layer.borderWidth = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        inputImageView.image = nil
        remsetBorder()
    }
}
