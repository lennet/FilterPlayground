//
//  SelectObjectViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.12.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

protocol SelectObjectViewControllerPresentable {
    var title: String { get }
    var subtitle: String? { get }
    var image: UIImage? { get }
    var interactionEnabled: Bool { get }
}

struct GenericSelectObjectViewControllerPresentable: SelectObjectViewControllerPresentable {
    var title: String

    var subtitle: String?

    var image: UIImage?

    var interactionEnabled: Bool
}

class SelectObjectController: UINavigationController, UIPopoverPresentationControllerDelegate {
    public var enforcePresentationStyle: Bool = false

    init(title: String? = nil, objects: [[SelectObjectViewControllerPresentable]], style: UITableViewStyle = .plain, callback: @escaping (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void) {
        let rootViewController = SelectObjectViewController(title: title, objects: objects, style: style, callback: callback)
        super.init(nibName: nil, bundle: nil)
        viewControllers = [rootViewController]
        popoverPresentationController?.delegate = self
    }

    var callback: (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void {
        get {
            return (viewControllers.first as! SelectObjectViewController).callback
        }
        set {
            (viewControllers.first as! SelectObjectViewController).callback = newValue
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Mark: UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if enforcePresentationStyle {
            return .none
        }
        return controller.adaptivePresentationStyle(for: traitCollection)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            (self.viewControllers.first as! SelectObjectViewController).configureCancelButton(arrowDirection: self.popoverPresentationController?.arrowDirection ?? .unknown, animated: true)
        }
    }
}

class SelectObjectViewController: UITableViewController {
    fileprivate var objects: [[SelectObjectViewControllerPresentable]]
    fileprivate var callback: (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void

    init(title: String? = nil, objects: [[SelectObjectViewControllerPresentable]], style: UITableViewStyle = .plain, callback: @escaping (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void) {
        self.objects = objects
        self.callback = callback
        super.init(style: style)
        self.title = title
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = SelectObjectTableView(frame: view.bounds, objects: objects, callback: { presentable, _ in
            self.callback(presentable, self)
            self.dismiss(animated: true, completion: nil)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: preferredContentSize.width, height: tableView.contentSize.height)

        configureCancelButton(arrowDirection: navigationController?.popoverPresentationController?.arrowDirection ?? .unknown)
    }

    func configureCancelButton(arrowDirection: UIPopoverArrowDirection, animated: Bool = false) {
        if arrowDirection == .unknown ||
            traitCollection.userInterfaceIdiom == .phone {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            navigationItem.setRightBarButton(cancelButton, animated: animated)
        } else {
            navigationItem.setRightBarButton(nil, animated: animated)
        }
    }

    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
