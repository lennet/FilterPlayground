//
//  ErrorViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 14.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

// TODO: use the scrollViews drag to hide the ErrorView
class ErrorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var errorTableView: UITableView!

    @IBOutlet var headerViewLabelContainer: UIStackView!
    @IBOutlet var compileErrorView: UIView!
    @IBOutlet var compileWarningView: UIView!
    @IBOutlet var runTimeErrorView: UIView!
    @IBOutlet var runTimeErrorLabel: UILabel!
    @IBOutlet var compileErrorLabel: UILabel!
    @IBOutlet var compileWarningLabel: UILabel!

    var headerHeight: CGFloat {
        return headerView.bounds.height
    }

    var maxHeight: CGFloat = 0
    var shouldHighLight: ((_ lineNumbers: Set<Int>) -> Void)?
    var shouldUpdateHeight: ((_ newHeight: CGFloat, _ animated: Bool) -> Void)?
    var heightChangedObserverToken: NSKeyValueObservation?

    var errors: [KernelError] = [] {
        didSet {
            didUpateErrros(with: oldValue)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        headerView.layer.cornerRadius = 8
        headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPan(gestureRecnogizer:)))
        headerView.addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(gestureRecnogizer:)))
        headerView.addGestureRecognizer(tapGestureRecognizer)

        headerViewLabelContainer.alpha = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        heightChangedObserverToken?.invalidate()
    }

    func didUpateErrros(with oldValue: [KernelError]) {
        guard errors != oldValue else { return }
        guard errors.count > 0 else {
            shouldUpdateHeight?(0, true)
            return
        }
        errorTableView.reloadData()
        errorTableView.layoutIfNeeded()
        let screenHeight = UIApplication.shared.keyWindow?.frame.height ?? 0
        maxHeight = min(errorTableView.contentSize.height + headerHeight * 2, screenHeight / 4)

        if view.bounds.height == 0 {
            shouldUpdateHeight?(maxHeight, true)
        }

        let compileErrors = errors.filter { !$0.isRuntime }

        let compileErrorsCount = compileErrors.filter { !$0.isWarning }.count
        compileErrorLabel.text = "\(compileErrorsCount)"
        compileErrorView.isHidden = compileErrorsCount <= 0

        let warningsCount = compileErrors.count - compileErrorsCount
        compileWarningLabel.text = "\(warningsCount)"
        compileWarningView.isHidden = warningsCount <= 0

        let runTimeErrorsCount = errors.filter { $0.isRuntime }.count
        runTimeErrorLabel.text = "\(runTimeErrorsCount)"
        runTimeErrorView.isHidden = runTimeErrorsCount <= 0
    }

    func setAlpha(value: CGFloat, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.headerViewLabelContainer.alpha = value
        }
    }

    @objc func handleHeaderPan(gestureRecnogizer: UIPanGestureRecognizer) {
        var newHeight: CGFloat = 0
        var shouldAnimatedUpdate = false

        switch gestureRecnogizer.state {
        case .cancelled,
             .ended:
            let velocity = gestureRecnogizer.velocity(in: headerView)
            shouldAnimatedUpdate = true
            if velocity.y < 0 {
                newHeight = maxHeight
                setAlpha(value: 0, animated: false)
            } else {
                newHeight = headerHeight
                setAlpha(value: 1, animated: false)
            }
            break
        default:
            let translation = gestureRecnogizer.translation(in: headerView)
            gestureRecnogizer.setTranslation(.zero, in: headerView)

            newHeight = view.bounds.height - translation.y
            newHeight = max(newHeight, headerHeight)
            newHeight = min(newHeight, maxHeight)
            setAlpha(value: 1 - newHeight.noramlized(min: headerHeight, max: maxHeight), animated: false)
            // TODO: use different timing curve
            break
        }

        shouldUpdateHeight?(newHeight, shouldAnimatedUpdate)
    }

    @objc func handleHeaderTap(gestureRecnogizer _: UITapGestureRecognizer) {
        var newHeight: CGFloat = 0
        var newAlpha: CGFloat = 0
        if view.bounds.height > headerHeight {
            newHeight = headerHeight
            newAlpha = 1
        } else {
            newHeight = maxHeight
            newAlpha = 0
        }

        shouldUpdateHeight?(newHeight, true)
        setAlpha(value: newAlpha, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        errorTableView.isScrollEnabled = errorTableView.contentSize.height > errorTableView.bounds.height
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return errors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "errorCellIdentifier") as! ErrorTableViewCell
        cell.error = errors[indexPath.row]
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch errors[indexPath.row] {
        case .compile(lineNumber: let lineNumber, characterIndex: _, type: _, message: _, note: let note):
            var lineNumbers = Set([lineNumber])
            if let note = note {
                lineNumbers.insert(note.lineNumber)
            }
            shouldHighLight?(lineNumbers)
            break
        case .runtime(message: _):
            break
        }
    }
}
