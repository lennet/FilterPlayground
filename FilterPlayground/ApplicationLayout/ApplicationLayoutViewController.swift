//
//  ApplicationLayoutViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 09.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class ApplicationLayoutViewController: UIViewController {
    let subNavigationController = UINavigationController(nibName: nil, bundle: nil)
    let pipContainer = PIPContainerView()
    let outerStackView = UIStackView()

    let sourceEditorController = UIStoryboard.main.instantiate(viewController: SourceEditorViewController.self)
    let attributesViewController = UIStoryboard.main.instantiate(viewController: AttributesViewController.self)
    let liveViewController = UIStoryboard.main.instantiate(viewController: LiveViewController.self)

    let innerLayoutController = ApplicationInnerLayoutViewController(nibName: nil, bundle: nil)

    init() {
        super.init(nibName: nil, bundle: nil)
        keyboardObserver = KeyboardObserver(callback: keyboardChanged)
        keyboardObserver.startObserving()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var keyboardObserver: KeyboardObserver!
    let mainController = MainController()

    var isMinified: Bool {
        if traitCollection.userInterfaceIdiom == .phone {
            return true
        }
        return traitCollection.horizontalSizeClass == .compact
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainController()

        innerLayoutController.addChildViewController(sourceEditorController)
        subNavigationController.viewControllers = [innerLayoutController]

        outerStackView.frame = view.bounds
        outerStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        outerStackView.addArrangedSubview(subNavigationController.view)
        outerStackView.distribution = .fillEqually

        if UIDevice.current.userInterfaceIdiom == .phone {
            pipContainer.addSubview(liveViewController.view)
            outerStackView.addArrangedSubview(pipContainer)
        } else {
            innerLayoutController.secondViewController = liveViewController
            innerLayoutController.thirdViewController = attributesViewController
        }

        view.addSubview(outerStackView)
        innerLayoutController.firstViewController = sourceEditorController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attributesViewController.loadViewIfNeeded()
        presentDocumentPickerIfNeeded()
    }

    func configureMainController() {
        mainController.liveViewController = liveViewController
        mainController.attributesViewController = attributesViewController
        mainController.sourceEditorViewController = sourceEditorController
    }

    func configureNavigationController() {
        var rightItems: [UIBarButtonItem] = []

        let attributesBarbuttonItem = UIBarButtonItem(title: "Attributes", style: .plain, target: self, action: #selector(attributesButtonTapped))

        let runBarbuttonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(runButtonTapped))
        rightItems.append(contentsOf: [runBarbuttonItem, attributesBarbuttonItem])

        if traitCollection.userInterfaceIdiom == .phone && keyboardObserver.isKeyboardVisible {
            let dismissKeyboardBarbuttonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "DismissKeyboard"), style: .plain, target: self, action: #selector(dismissKeyboardButtonTapped))
            rightItems.append(dismissKeyboardBarbuttonItem)
        }
        innerLayoutController.navigationItem.setRightBarButtonItems(rightItems, animated: false)

        var leftItems: [UIBarButtonItem] = []
        let documentsBarbuttonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(documentsButtonTapped(sender:)))
        let settingsBarbuttonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsButtonTapped(sender:)))
        let exportBarbuttonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportButtonTapped(sender:)))
        leftItems.append(contentsOf: [documentsBarbuttonItem, settingsBarbuttonItem, exportBarbuttonItem])
        innerLayoutController.navigationItem.setLeftBarButtonItems(leftItems, animated: false)
    }

    func presentDocumentPickerIfNeeded() {
        if mainController.project == nil {
            let documentBrowser = UIStoryboard.main.instantiate(viewController: DocumentBrowserViewController.self)
            documentBrowser.didOpenedDocument = { document in
                self.presentedViewController?.dismiss(animated: true, completion: nil)
                self.mainController.didOpened(document: document)
            }
            documentBrowser.modalPresentationStyle = .formSheet
            present(documentBrowser, animated: true, completion: nil)
        }
    }

    @objc func attributesButtonTapped() {
        if isMinified {
            innerLayoutController.navigationController?.pushViewController(attributesViewController, animated: true)
        } else {
            innerLayoutController.toggleThirdViewControllerVisibility(with: attributesViewController)
        }
    }

    @objc func runButtonTapped() {
        mainController.run()
    }

    @objc func dismissKeyboardButtonTapped() {
        sourceEditorController.textView.textView.resignFirstResponder()
    }

    @objc func settingsButtonTapped(sender: UIBarButtonItem) {
        let settings = UIStoryboard.main.instantiate(viewController: SettingsTableViewController.self)
        settings.modalPresentationStyle = .popover
        settings.popoverPresentationController?.barButtonItem = sender

        present(settings, animated: true, completion: nil)
    }

    @objc func documentsButtonTapped(sender: UIBarButtonItem) {
        let documents = UIStoryboard.main.instantiate(viewController: DocumentBrowserViewController.self)
        documents.modalPresentationStyle = .popover
        documents.popoverPresentationController?.barButtonItem = sender
        documents.didOpenedDocument = mainController.didOpened

        present(documents, animated: true, completion: nil)
    }

    @objc func exportButtonTapped(sender: UIBarButtonItem) {
        guard let project = mainController.project else { return }
        let export = ExportOptionsViewController(project: project, showCompileWarning: sourceEditorController.errors.count != 0)
        export.modalPresentationStyle = .popover
        export.popoverPresentationController?.barButtonItem = sender
        present(export, animated: true, completion: nil)
    }

    @objc func increaseFontSize() {
        sourceEditorController.fontSize += 3
    }

    @objc func decreaseFontSize() {
        sourceEditorController.fontSize -= 3
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceIdiom == .pad {
            if traitCollection.horizontalSizeClass == .compact {
                innerLayoutController.secondViewController = nil
                innerLayoutController.thirdViewController = nil
                addChildViewController(liveViewController)
                pipContainer.addSubview(liveViewController.view)
                outerStackView.addArrangedSubview(pipContainer)
                outerStackView.axis = .vertical
            } else {
                liveViewController.removeFromParentViewController()
                liveViewController.view.removeFromSuperview()
                pipContainer.removeFromSuperview()
                innerLayoutController.secondViewController = liveViewController
                innerLayoutController.thirdViewController = attributesViewController
            }
        } else if traitCollection.userInterfaceIdiom == .phone {
            outerStackView.axis = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight ? .horizontal : .vertical
        }
    }

    func keyboardChanged(with _: KeyboardEvent, object _: KeyboardNotificationObject) {
        configureNavigationController()
    }

    override var keyCommands: [UIKeyCommand]? {
        let toggleAttributesKeyCommand = UIKeyCommand(input: "0", modifierFlags: .command, action: #selector(attributesButtonTapped), discoverabilityTitle: innerLayoutController.isThirdViewVisible ? 🌎("KeyCommand_HideAttributes") : 🌎("KeyCommand_ShowAttributes"))
        let runKeyCommand = UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(runButtonTapped), discoverabilityTitle: 🌎("KeyCommand_Run"))
        let increaseFontKeyCommand = UIKeyCommand(input: "+", modifierFlags: .command, action: #selector(increaseFontSize), discoverabilityTitle: 🌎("KeyCommand_IncreaseFont"))
        let increaseFontKeyCommandUSKeyboard = UIKeyCommand(input: "=", modifierFlags: .command, action: #selector(increaseFontSize))
        let decreaseFontKeyCommand = UIKeyCommand(input: "-", modifierFlags: .command, action: #selector(decreaseFontSize), discoverabilityTitle: 🌎("KeyCommand_DecreaseFont"))
        return [runKeyCommand, increaseFontKeyCommand, increaseFontKeyCommandUSKeyboard, decreaseFontKeyCommand, toggleAttributesKeyCommand]
    }
}
