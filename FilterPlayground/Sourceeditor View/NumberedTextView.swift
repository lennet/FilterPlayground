//
//  NumberedTextView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class NumberedTextView: UIView, UITextViewDelegate {

    let textView: UITextView = {
        let textView = UITextView()
        textView.autoresizingMask = UIViewAutoresizing.flexibleHeight.union(.flexibleWidth)
        return textView
    }()
    
    weak var delegate: UITextViewDelegate?
    var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textView.frame = CGRect(origin: CGPoint(x:20, y:0), size: CGSize(width: frame.width - 20, height: frame.height))
        textView.delegate = self
        addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textView.frame = CGRect(origin: CGPoint(x:20, y:0), size: CGSize(width: frame.width - 20, height: frame.height))
        textView.delegate = self
        addSubview(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        var lineRange = NSMakeRange(0, 1)
        var index = 0
        var lineNumber = 0
        
        // todo check for cursor position
        
        while index < textView.layoutManager.numberOfGlyphs {
            let lineRect = textView.layoutManager.lineFragmentUsedRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            lineNumber += 1
            
            let y = lineRect.origin.y - textView.contentOffset.y + textView.textContainerInset.top
            if y > -(textView.font?.lineHeight ?? 10) {
                ("\(lineNumber) :" as NSString).draw(at: CGPoint(x: 0, y: y), withAttributes: [NSAttributedStringKey.font:textView.font!])
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsDisplay()
    }
    
}
