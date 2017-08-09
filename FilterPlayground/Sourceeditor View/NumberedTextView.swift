//
//  NumberedTextView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class NumberedTextView: UIView, UITextViewDelegate {
    
    var theme: Theme.Type {
        return ThemeManager.shared.currentTheme
    }

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
            renderText()
            setNeedsDisplay()
        }
    }
    
    var currentAST: ASTNode?
    
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
//            guard let newValue = newValue else { return }
//            textView.contentInset.left = newValue.pointSize
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        textView.frame = CGRect(origin: CGPoint(x:30, y:0), size: CGSize(width: frame.width - 20, height: frame.height))
        textView.delegate = self
        contentMode = .topLeft
        addSubview(textView)
        backgroundColor = .clear
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setNeedsDisplay()
        renderText()
    }
    
    func renderText() {
        let selectedRange = textView.selectedRange
        let parser = Parser(string: textView.text)
        let oldFont = font
        currentAST = parser.getAST()
        textView.attributedText = currentAST?.asAttributedText
        textView.selectedRange = selectedRange
        textView.font = oldFont
        delegate?.textViewDidChange?(textView)
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
                fillLine(rect: CGRect(origin:lineRect.origin, size: CGSize(width: rect.width, height: lineRect.height)), color: theme.sourceEditorLineBackgroundError)
            } else if lineRange.contains(textView.selectedRange.location) && textView.selectedRange.length == 0 {
                fillLine(rect: CGRect(origin:lineRect.origin, size: CGSize(width: rect.width, height: lineRect.height)), color: theme.sourceEditorLineBackgroundHighlighted)
            }
            
            if lineRect.origin.y > -(textView.font?.lineHeight ?? 10) {
                draw(text: "\(lineNumber) :", at: lineRect.origin, color: theme.sourceEditorLineNumber)
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
    
    func draw(text: String, at point: CGPoint, color: UIColor) {
        let attributes = [NSAttributedStringKey.font:textView.font!,
                          NSAttributedStringKey.foregroundColor: color] as [NSAttributedStringKey : Any]
        (text as NSString).draw(at: CGPoint(x: 0, y: point.y), withAttributes: attributes)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" && range.length == 0 {
//            var newText = text
//            newText += Array(repeating: "\t", count: currentAST?.intendationLevel(at: range.location, with: 1) ?? 0).joined()
//            textView.text = textView.text.replacingCharacters(in: Range(range, in: textView.text)!, with: newText)
//            return false
//        }
//        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        setNeedsDisplay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsDisplay()
    }
    
}
