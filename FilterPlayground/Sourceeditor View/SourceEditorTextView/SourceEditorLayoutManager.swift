//
//  SourceEditorLayoutManager.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 23.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SourcEditorLayoutManager: NSLayoutManager {
    
    var lastIndex = 0
    var lastLocation = 0
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        enumerateLineFragments(forGlyphRange: glyphsToShow) { (rect, usedRect, textContainer, range, stop) in
            
            if range.location > self.lastLocation {
                self.lastIndex += 1
            } else if range.location < self.lastLocation {
                self.lastIndex -= 1
            }
            self.lastLocation = range.location
            
            
            let point = CGPoint(x: origin.x + rect.origin.x, y: origin.y + rect.origin.y)
            ("\(self.lastIndex)" as NSString).draw(at: point, withAttributes: nil)
        }
    }
    
}
