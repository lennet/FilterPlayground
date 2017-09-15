//
//  LiveViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {

    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var imageView: CustomImageView!
    @IBOutlet var inputImageViews: [CustomImageView]!
    @IBOutlet var labels: [UILabel]!
    var didUpdateInputImages: (([UIImage]) -> Void)?
    var highlightEmptyInputImageViews = false {
        didSet {
            inputImageViews.forEach { imageView in
                // todo fade
                imageView.layer.borderColor = self.highlightEmptyInputImageViews ? UIColor.red.withAlphaComponent(0.7).cgColor : UIColor.clear.cgColor
                imageView.layer.borderWidth = self.highlightEmptyInputImageViews ? 2 : 0
            }
        }
    }

    var numberOfInputs: Int = 2 {
        didSet {

            switch numberOfInputs {
            case 2:
                inputImageViews.forEach { $0.isHidden = false }
                inputStackView.isHidden = false
                labels.forEach { $0.isHidden = false }
                break
            case 1:
                inputStackView.isHidden = false
                labels.forEach { $0.isHidden = false }
                inputImageViews.last?.isHidden = true
                break
            default:
                inputStackView.isHidden = true
                labels.forEach { $0.isHidden = true }
                break
            }

            themeChanged(notification: nil)
        }
    }

    var inputImages: [UIImage] {
        get {
            return inputImageViews.flatMap { $0.image }
        }
        set {
            inputImageViews.forEach { $0.image = nil }
            for (index, image) in newValue.enumerated() where index < inputImageViews.count {
                inputImageViews[index].image = image
            }
            imageView.image = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        inputImageViews.forEach { $0.accessibilityIgnoresInvertColors = true }
        inputImageViews.forEach { $0.didSelectImage = didSelectImage }
        imageView.accessibilityIgnoresInvertColors = true
        imageView.canSelectImage = false
    }

    func didSelectImage(imageView _: CustomImageView) {
        didUpdateInputImages?(inputImages)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func reset() {
        imageView.image = nil
        inputImageViews.forEach { $0.image = nil }
    }

    @objc func themeChanged(notification _: Notification?) {
        view.backgroundColor = ThemeManager.shared.currentTheme.liveViewBackground
        inputImageViews.forEach { $0.backgroundColor = ThemeManager.shared.currentTheme.imageViewBackground }
        if numberOfInputs > 0 {
            imageView.backgroundColor = ThemeManager.shared.currentTheme.imageViewBackground
        } else {
            imageView.backgroundColor = .clear
        }
        labels.forEach { $0.textColor = ThemeManager.shared.currentTheme.liveViewLabel }
    }
}
