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

    var metaData: ProjectMetaData = ProjectMetaData(attributes: [], type: .warp)
    var source: String = "" {
        didSet {
            self.updateChangeCount(.done)
        }
    }
    
    convenience init(fileURL url: URL, type: KernelType) {
        self.init(fileURL: url)
        metaData.type = type
        source = metaData.initialSource()
    }
    
    override init(fileURL url: URL) {
        super.init(fileURL: url)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        let meta = try JSONEncoder().encode(metaData)
        
        guard let sourceData = source.data(using: .utf8) else {
            throw DocumentError.encodeError
        }
        
        let fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
        fileWrapper.addRegularFile(withContents: meta   , preferredFilename: "metadata.json")
        fileWrapper.addRegularFile(withContents: sourceData,  preferredFilename: "content")
        return fileWrapper
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
    
        guard let filewrapper = contents as? FileWrapper else {
            throw DocumentError.unknownFileFormat
        }
        
        guard let metaFilewrapper = filewrapper.fileWrappers?["metadata.json"] else {
            throw DocumentError.unknownFileFormat
        }
        
        guard let meta = metaFilewrapper.regularFileContents else {
            throw DocumentError.unknownFileFormat
        }
        
        self.metaData = try JSONDecoder().decode(ProjectMetaData.self, from: meta)
        
        guard let contentFilewrapper = filewrapper.fileWrappers?["content"] else {
            throw DocumentError.unknownFileFormat
        }

        guard let contentsData = contentFilewrapper.regularFileContents else {
            throw DocumentError.unknownFileFormat
        }
        
        guard let sourceString = String(data: contentsData, encoding: .utf8) else {
            throw DocumentError.unknownFileFormat
        }
        
        self.source = sourceString
    }

    override func save(to url: URL, for saveOperation: UIDocumentSaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
        super.save(to: url, for: saveOperation, completionHandler: completionHandler)
    }
    
}
