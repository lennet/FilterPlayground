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

    var metaData: ProjectMetaData = ProjectMetaData(attributes: [:], type: .warp)
    var source: String = "" {
        didSet {
            self.updateChangeCount(.done)
        }
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
        
        guard let metaFilewrapper = filewrapper.fileWrappers?["metadata"] else {
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

    
}
