//
//  ExportOptionsViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class ExportOptionsViewController: SelectObjectController {
    var project: Project

    init(project: Project, showCompileWarning: Bool) {
        self.project = project
        let tableViewStyle: UITableViewStyle = showCompileWarning ? .grouped : .plain
        var objects: [[SelectObjectViewControllerPresentable]] = [[
            ExportOption(title: 🌎("Export_CIKernel_Label"), action: #selector(exportAsCIKernel)),
            ExportOption(title: 🌎("Export_CIFilter_Label"), action: #selector(exportAsCIFilter)),
            ExportOption(title: 🌎("Export_SwiftPlayground_Label"), action: #selector(exportAsSwiftPlayground)),
            ExportOption(title: 🌎("Export_FilterPlayground_Label"), action: #selector(exportAsPlayground)),
        ]]
        if showCompileWarning {
            objects.insert([ExportWarningObject()], at: 0)
        }
        super.init(title: "Export", objects: objects, style: tableViewStyle) { _, _ in }
        callback = tappedOptions
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tappedOptions(exportOption: SelectObjectViewControllerPresentable, vc: SelectObjectViewController) {
        var senderView: UIView?
        if let selectedIndexPath = vc.tableView.indexPathForSelectedRow {
            senderView = vc.tableView.cellForRow(at: selectedIndexPath)
        }

        perform((exportOption as! ExportOption).action, with: senderView)
    }

    @objc func exportAsSwiftPlayground(sender: UIView?) {
        let name = project.localizedName.withoutWhiteSpaces.withoutSlash
        let inputImages = project.metaData.inputImages.compactMap { $0.image }.compactMap(UIImagePNGRepresentation)
        let playground = SwiftPlaygroundsExportHelper.swiftPlayground(with: name, type: project.metaData.type, kernelSource: project.source, arguments: project.metaData.arguments, inputImages: inputImages)
        presentActivityViewController(sourceView: sender, items: [playground])
    }

    @objc func exportAsPlayground(sender: UIView?) {
        project.save(to: project.fileURL, for: .forOverwriting) { _ in
            self.presentActivityViewController(sourceView: sender, items: [self.project.fileURL])
        }
    }

    @objc func exportAsCIFilter(sender: UIView?) {
        guard
            let sourceData = CIFilterExportHelper.cifilter(with: project.source, type: project.metaData.type, arguments: project.metaData.arguments, name: project.localizedName.withoutWhiteSpaces.withoutSlash).data(using: .utf8) else {
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(project.localizedName.withoutWhiteSpaces.withoutSlash).swift")

        do {
            try sourceData.write(to: url, options: .atomicWrite)

        } catch {
            print(error)
            // TODO: handle error
            return
        }
        presentActivityViewController(sourceView: sender, items: [url])
    }

    @objc func exportAsCIKernel(sender: UIView?) {
        guard let sourceData = project.source.data(using: .utf8) else {
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(project.localizedName.withoutWhiteSpaces.withoutSlash).CIKernel")

        do {
            try sourceData.write(to: url, options: .atomicWrite)
        } catch {
            print(error)
            // TODO: handle error
            return
        }
        presentActivityViewController(sourceView: sender, items: [url])
    }

    func presentActivityViewController(sourceView: UIView?, items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            self.dismiss(animated: true, completion: nil)
        }
        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.popoverPresentationController?.sourceRect = sourceView?.bounds ?? .zero
        UIApplication.shared.delegate?.window??.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

struct ExportWarningObject: SelectObjectViewControllerPresentable {
    var title: String {
        return 🌎("Export_CompileErrorsWarning_Label")
    }

    var subtitle: String? {
        return nil
    }

    var image: UIImage? {
        return #imageLiteral(resourceName: "CompilerWarning").resize(to: CGSize(width: 32, height: 32))
    }

    var interactionEnabled: Bool {
        return false
    }
}

struct ExportOption: SelectObjectViewControllerPresentable {
    var title: String
    var action: Selector

    var subtitle: String? {
        return nil
    }

    var image: UIImage? {
        return nil
    }

    var interactionEnabled: Bool {
        return true
    }
}
