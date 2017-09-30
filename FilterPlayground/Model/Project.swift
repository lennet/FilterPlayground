//
//  Document.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 01.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

enum ProjectError: Error {
    case unknownFileFormat
    case encodeError
}

class Project: UIDocument {

    static let type: String = "FilterPlayground"
    
    var resourcesWrapper = FileWrapper(directoryWithFileWrappers: [:])

    var metaData: ProjectMetaData = ProjectMetaData(attributes: [], type: .coreimagewarp)
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
            throw ProjectError.encodeError
        }

        let fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
        fileWrapper.addRegularFile(withContents: meta, preferredFilename: "metadata.json")
        fileWrapper.addRegularFile(withContents: sourceData, preferredFilename: "source.cikernel")

        if inputImages.count > 0 {
            let inputImagesFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
            for (index, image) in inputImages.enumerated() {
                inputImagesFileWrapper.addRegularFile(withContents: UIImagePNGRepresentation(image)!, preferredFilename: "\(index).png")
            }

            inputImagesFileWrapper.preferredFilename = "inputimages"
            fileWrapper.addFileWrapper(inputImagesFileWrapper)
        }
        
        resourcesWrapper = FileWrapper(directoryWithFileWrappers: [:])
        metaData.attributes.forEach { argument in
            guard case .sample(let image) = argument.value else { return }
            self.addImage(image: image, for: argument.name)
        }
        
        resourcesWrapper.preferredFilename = "Resources"
        fileWrapper.addFileWrapper(resourcesWrapper)

        return fileWrapper
    }
    
    func addImage(image: CIImage, for name: String) {
        guard let data = image.asPNGData else { return }
        addResource(for: "\(name).png", with: data)
    }
    
    func getImage(for name: String) -> CIImage? {
        guard let child = resourcesWrapper.fileWrappers?["\(name).png" ],
            let data = child.regularFileContents else { return nil }
        return CIImage(data: data)
    }
    
    func renameImage(for name: String, with newName: String) {
        renameResouce(for: "\(name).png", with: "\(newName).png")
    }
    
    func addResource(for name: String, with data: Data) {
        resourcesWrapper.addRegularFile(withContents: data, preferredFilename: name)
    }
    
    func getAllResources() -> [(name: String, data: Data)] {
        return resourcesWrapper.fileWrappers?.values.flatMap {
            guard let data = $0.regularFileContents,
                let name = $0.preferredFilename else { return nil}
            return (name: name,data: data)
        } ?? []
    }
    
    func removeResource(for name: String) {
        guard let child = resourcesWrapper.fileWrappers?[name] else { return }
        resourcesWrapper.removeFileWrapper(child)
    }
    
    func renameResouce(for name: String, with newName: String) {
        guard let child = resourcesWrapper.fileWrappers?[name],
            let data = child.regularFileContents else { return }
        removeResource(for: name)
        addResource(for: newName, with: data)
    }

    override func load(fromContents contents: Any, ofType _: String?) throws {

        guard let filewrapper = contents as? FileWrapper else {
            throw ProjectError.unknownFileFormat
        }

        guard let metaFilewrapper = filewrapper.fileWrappers?["metadata.json"] else {
            throw ProjectError.unknownFileFormat
        }

        guard let meta = metaFilewrapper.regularFileContents else {
            throw ProjectError.unknownFileFormat
        }

        metaData = try JSONDecoder().decode(ProjectMetaData.self, from: meta)

        guard let contentFilewrapper = filewrapper.fileWrappers?["source.cikernel"] else {
            throw ProjectError.unknownFileFormat
        }

        guard let contentsData = contentFilewrapper.regularFileContents else {
            throw ProjectError.unknownFileFormat
        }
 
        guard let sourceString = String(data: contentsData, encoding: .utf8) else {
            throw ProjectError.unknownFileFormat
        }
        
        if let resourcesFilewrapper = filewrapper.fileWrappers?["Resources"] {
           resourcesWrapper = resourcesFilewrapper
        }
        
        metaData.attributes = metaData.attributes.flatMap { argument in
            guard case .sample = argument.type else { return argument }
            return KernelAttribute(name: argument.name, type: argument.type, value:  .sample(self.getImage(for: argument.name)!))
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
