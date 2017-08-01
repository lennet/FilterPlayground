//
//  Document.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 01.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class Document: UIDocument {

    override func contents(forType typeName: String) throws -> Any {
        let content = FileWrapper(regularFileWithContents: Data())
        let metadata = FileWrapper(regularFileWithContents: Data())
        return FileWrapper(directoryWithFileWrappers: ["content": content,
                                                                  "metadata": metadata])
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }

    
}
