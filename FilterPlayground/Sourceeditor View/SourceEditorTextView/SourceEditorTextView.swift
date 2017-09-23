//
//  SourceEditorTextView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 19.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SourceEditorTextView: UITextView {
    
    var attribtutedStringForString: ((String) -> NSAttributedString)?{
        set {
            (textStorage as? SourceEditorTextStorage)?.attribtutedStringForString = newValue
        }
        get {
            return (textStorage as? SourceEditorTextStorage)?.attribtutedStringForString
        }
    }
    
    init(frame: CGRect) {
        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        let storage = SourceEditorTextStorage()
        storage.addLayoutManager(layoutManager)
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
