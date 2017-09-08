//
//  TemplatesManager.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class TemplatesManager {
    
    class func getURLs() -> [URL] {
        let paths = Bundle.main.paths(forResourcesOfType: Document.type, inDirectory: nil)
        return paths.map(URL.init(fileURLWithPath:))
    }
    
}
