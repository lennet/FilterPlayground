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
        textView.backgroundColor = .clear
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
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
            textViewDidChange(textView)
        }
    }
    
    var font: UIFont? {
        get {
            return textView.font
        }
        set {
            textView.font = newValue
            // todo calculate max contentInset
            guard let newValue = newValue else { return }
            textView.contentInset.left = newValue.pointSize
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
        
        let selectedRange = textView.selectedRange
        let parser = Parser(string: textView.text)
        let oldFont = font
        textView.attributedText = Renderer.rederAsAttributedString(tokens: parser.getTokens())
        textView.selectedRange = selectedRange
        textView.font = oldFont
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect) 
        
        var lineRange = NSMakeRange(0, 1)
        var index = 0
        var lineNumber = 0
        
        while index < textView.layoutManager.numberOfGlyphs {
            var lineRect = textView.layoutManager.lineFragmentUsedRect(forGlyphAt: index, effectiveRange: &lineRange)
            lineRect.origin.y = lineRect.origin.y - textView.contentOffset.y + textView.textContainerInset.top
            index = NSMaxRange(lineRange)
            lineNumber += 1
            
            if lineRange.contains(textView.selectedRange.location) && textView.selectedRange.length == 0 {
                UIColor.blue.withAlphaComponent(0.1).setFill()
                var fillRect = lineRect
                fillRect.size.width = rect.width
                UIGraphicsGetCurrentContext()?.fill(fillRect)
                UIColor.black.setFill()
            }
            
            if lineRect.origin.y > -(textView.font?.lineHeight ?? 10) {
                ("\(lineNumber) :" as NSString).draw(at: CGPoint(x: 0, y: lineRect.origin.y), withAttributes: [NSAttributedStringKey.font:textView.font!])
            }
    
            if lineRect.origin.y > frame.size.height {
                break
            }
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        setNeedsDisplay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsDisplay()
    }
    
}
