//
//  ExportTableViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 18.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

struct ExportOption {
    var title: String
    var action: ((UIView?) -> Void)
}

class ExportTableViewController: UITableViewController {

    var document: Project?
    var showCompileWarning: Bool = false
    var exportOptions: [ExportOption] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: define options depending on the shading language

        exportOptions = [
            ExportOption(title: "CIKernel", action: exportAsCIKernel),
            ExportOption(title: "CIFilter", action: exportAsCIFilter),
            ExportOption(title: "Swift Playground", action: exportAsSwiftPlayground),
            ExportOption(title: "Filter Playground", action: exportAsPlayground),
        ]
    }

    @IBAction func tappedCancelButton() {
        dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return showCompileWarning ? 2 : 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showCompileWarning && section == 0 {
            return 1
        } else {
            return exportOptions.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellIdentifier", for: indexPath)

        if showCompileWarning && indexPath.section == 0 {
            cell.imageView?.image = #imageLiteral(resourceName: "CompilerWarning").resize(to: CGSize(width: 32, height: 32))
            cell.textLabel?.text = "Your code contains unresolved errors. An export will contain errors as well."
            cell.textLabel?.numberOfLines = 0
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
        } else {
            let option = exportOptions[indexPath.row]
            cell.textLabel?.text = option.title
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !showCompileWarning || indexPath.section != 0 else {
            return
        }

        let sender = tableView.cellForRow(at: indexPath)
        let option = exportOptions[indexPath.row]
        option.action(sender)
    }

    func exportAsSwiftPlayground(sender: UIView?) {
        guard let document = document else {
            return
        }

        let name = document.localizedName.withoutWhiteSpaces.withoutSlash
        let inputImages = document.metaData.inputImages.flatMap { $0.image }.flatMap(UIImagePNGRepresentation)
        let playground = SwiftPlaygroundsExportHelper.swiftPlayground(with: name, type: document.metaData.type, kernelSource: document.source, arguments: document.metaData.arguments, inputImages: inputImages)
        presentActivityViewController(sourceView: sender, items: [playground])
    }

    func exportAsPlayground(sender: UIView?) {
        guard let document = document else {
            return
        }
        document.save(to: document.fileURL, for: .forOverwriting) { _ in
            self.presentActivityViewController(sourceView: sender, items: [document.fileURL])
        }
    }

    func exportAsCIFilter(sender: UIView?) {
        guard let document = document,
            let sourceData = CIFilterExportHelper.cifilter(with: document.source, type: document.metaData.type, arguments: document.metaData.arguments, name: document.localizedName.withoutWhiteSpaces.withoutSlash).data(using: .utf8) else {
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(document.localizedName.withoutWhiteSpaces.withoutSlash).swift")

        do {
            try sourceData.write(to: url, options: .atomicWrite)

        } catch {
            print(error)
            // TODO: handle error
            return
        }
        presentActivityViewController(sourceView: sender, items: [url])
    }

    func exportAsCIKernel(sender: UIView?) {
        guard let document = document,
            let sourceData = document.source.data(using: .utf8) else {
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(document.localizedName.withoutWhiteSpaces.withoutSlash).CIKernel")

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
        present(activityViewController, animated: true, completion: nil)
    }
}
