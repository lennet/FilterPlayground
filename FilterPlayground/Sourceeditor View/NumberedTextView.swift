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
    
    var hightLightErrorLineNumber: Int? {
        didSet {
            setNeedsDisplay()
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
            
            if (hightLightErrorLineNumber ?? -1) == lineNumber {
                fillLine(rect: CGRect(origin:lineRect.origin, size: CGSize(width: rect.width, height: lineRect.height)), color: UIColor.red.withAlphaComponent(0.1))
            } else if lineRange.contains(textView.selectedRange.location) && textView.selectedRange.length == 0 {
                fillLine(rect: CGRect(origin:lineRect.origin, size: CGSize(width: rect.width, height: lineRect.height)), color: UIColor.blue.withAlphaComponent(0.1))
            }
            
            if lineRect.origin.y > -(textView.font?.lineHeight ?? 10) {
                draw(text: "\(lineNumber) :", at: lineRect.origin)
            }
    
            if lineRect.origin.y > frame.size.height {
                break
            }
            
            index = NSMaxRange(lineRange)
            lineNumber += 1
        }
    }
    
    func fillLine(rect: CGRect, color: UIColor) {
        color.setFill()
        UIGraphicsGetCurrentContext()?.fill(rect)
    }
    
    func draw(text: String, at point: CGPoint) {
        (text as NSString).draw(at: CGPoint(x: 0, y: point.y), withAttributes: [NSAttributedStringKey.font:textView.font!])
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        setNeedsDisplay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsDisplay()
    }
    
}
