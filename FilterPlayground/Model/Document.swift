//
//  Document.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 01.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

enum DocumentError: Error {
    case unknownFileFormat
    case encodeError
}

class Document: UIDocument {

    static let type: String = "kernelProj"

    var metaData: ProjectMetaData = ProjectMetaData(attributes: [], type: .warp)
    var source: String = "" {
        didSet {
            self.updateChangeCount(.done)
        }
    }

    var inputImages: [UIImage] = [] {
        didSet {
            self.updateChangeCount(.done)
        }
    }

    var title: String {
        return fileURL.lastPathComponent
    }

    convenience init(fileURL url: URL, type: KernelType) {
        self.init(fileURL: url)
        metaData.type = type
        source = metaData.initialSource()
        metaData.attributes = metaData.initalArguments()
        inputImages = metaData.initialInputImages()
    }

    override func contents(forType _: String) throws -> Any {
        let meta = try JSONEncoder().encode(metaData)

        guard let sourceData = source.data(using: .utf8) else {
            throw DocumentError.encodeError
        }

        let fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
        fileWrapper.addRegularFile(withContents: meta, preferredFilename: "metadata.json")
        fileWrapper.addRegularFile(withContents: sourceData, preferredFilename: "content")

        if inputImages.count > 0 {
            let inputImagesFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
            for (index, image) in inputImages.enumerated() {
                inputImagesFileWrapper.addRegularFile(withContents: UIImagePNGRepresentation(image)!, preferredFilename: "\(index).png")
            }

            inputImagesFileWrapper.preferredFilename = "inputimages"
            fileWrapper.addFileWrapper(inputImagesFileWrapper)
        }

        return fileWrapper
    }

    override func load(fromContents contents: Any, ofType _: String?) throws {

        guard let filewrapper = contents as? FileWrapper else {
            throw DocumentError.unknownFileFormat
        }

        guard let metaFilewrapper = filewrapper.fileWrappers?["metadata.json"] else {
            throw DocumentError.unknownFileFormat
        }

        guard let meta = metaFilewrapper.regularFileContents else {
            throw DocumentError.unknownFileFormat
        }

        metaData = try JSONDecoder().decode(ProjectMetaData.self, from: meta)

        guard let contentFilewrapper = filewrapper.fileWrappers?["content"] else {
            throw DocumentError.unknownFileFormat
        }

        guard let contentsData = contentFilewrapper.regularFileContents else {
            throw DocumentError.unknownFileFormat
        }

        guard let sourceString = String(data: contentsData, encoding: .utf8) else {
            throw DocumentError.unknownFileFormat
        }

        if let inputImagesFileWrapper = filewrapper.fileWrappers?["inputimages"] {
            var imageFound = true
            var index = 0
            while imageFound {
                if let data = inputImagesFileWrapper.fileWrappers?["\(index).png"]?.regularFileContents,
                    let image = UIImage(data: data) {
                    inputImages.append(image)
                } else {
                    imageFound = false
                }
                index += 1
            }
        }

        source = sourceString
    }

    override func save(to url: URL, for saveOperation: UIDocumentSaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
        super.save(to: url, for: saveOperation, completionHandler: completionHandler)
    }
}
