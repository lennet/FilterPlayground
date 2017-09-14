//
//  ErrorViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 14.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

// TODO use the scrollViews drag to hide the ErrorView
class ErrorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var errorTableView: UITableView!
    
    @IBOutlet weak var headerViewLabelContainer: UIStackView!
    @IBOutlet weak var compileErrorView: UIView!
    @IBOutlet weak var runTimeErrorView: UIView!
    @IBOutlet weak var runTimeErrorLabel: UILabel!
    @IBOutlet weak var compileErrorLabel: UILabel!
    
    var headerHeight: CGFloat {
        return headerView.bounds.height
    }
    
    var maxHeight: CGFloat = 0
    var shouldHighLight:((_ lineNumbers: Set<Int>) -> ())?
    var shouldUpdateHeight:((_ newHeight: CGFloat, _ animated: Bool) -> ())?
    var heightChangedObserverToken: NSKeyValueObservation?
 
    var errors: [KernelError] = [] {
        didSet {
            guard errors != oldValue else { return }
            errorTableView.reloadData()
            errorTableView.layoutIfNeeded()
            let screenHeight = UIApplication.shared.keyWindow?.frame.height ?? 0
            maxHeight = min(errorTableView.contentSize.height + headerHeight * 2, screenHeight / 4)
            
            if view.bounds.height == 0 {
                shouldUpdateHeight?(maxHeight, true)
            }
            
            let compileErrorsCount = errors.filter{ !$0.isRuntime }.count
            if compileErrorsCount > 0 {
                compileErrorLabel.text = "\(compileErrorsCount)"
                compileErrorView.isHidden = false
            } else {
                compileErrorView.isHidden = true
            }
            
            let runTimeErrorsCount = errors.filter{ $0.isRuntime }.count
            if runTimeErrorsCount > 0 {
                runTimeErrorLabel.text = "\(runTimeErrorsCount)"
                runTimeErrorView.isHidden = false
            } else {
                runTimeErrorView.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        headerView.layer.cornerRadius = 8
        headerView.layer.maskedCorners = CACornerMask.layerMaxXMinYCorner.union(.layerMinXMinYCorner)
        
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
            let velocity = gestureRecnogizer.velocity(in: self.headerView)
            shouldAnimatedUpdate = true
            if velocity.y < 0  {
                newHeight = maxHeight
                setAlpha(value: 0, animated: false)
            } else {
                newHeight = headerHeight
                setAlpha(value: 1, animated: false)
            }
            break
        default:
            let translation = gestureRecnogizer.translation(in: self.headerView)
            gestureRecnogizer.setTranslation(.zero, in: self.headerView)
            
            newHeight = view.bounds.height - translation.y
            newHeight = max(newHeight, headerHeight)
            newHeight = min(newHeight, maxHeight)
            setAlpha(value:  1-newHeight.noramlized(min: headerHeight, max: maxHeight), animated: false)
            // todo use different timing curve
            break
        }
        
        self.shouldUpdateHeight?(newHeight, shouldAnimatedUpdate)
    }
    
    @objc func handleHeaderTap(gestureRecnogizer: UITapGestureRecognizer) {
        var newHeight: CGFloat = 0
        var newAlpha: CGFloat = 0
        if view.bounds.height > headerHeight {
            newHeight = headerHeight
            newAlpha = 1
        } else {
            newHeight = maxHeight
            newAlpha = 0
        }
        
        self.shouldUpdateHeight?(newHeight, true)
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
        // todo show notes
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
