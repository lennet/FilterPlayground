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

    class var spacingValue: String {
        return Settings.tabsEnabled ? "\t" : "    "
    }

    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.autoresizingMask = UIViewAutoresizing.flexibleHeight.union(.flexibleWidth)
        (textView as UIScrollView).delaysContentTouches = false
        return textView
    }()

    weak var delegate: UITextViewDelegate?

    var didUpdateArguments: (([(String, KernelAttributeType)]) -> Void)?

    var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            updatedText()
            setNeedsDisplay()
        }
    }

    var currentAST: ASTNode?

    var hightLightErrorLineNumber: [Int] = [] {
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
            setNeedsLayout()
        }
    }

    var lineNumberOffset: CGFloat {
        return ("\(textView.text.numberOfLines) " as NSString).size(withAttributes: lineNumberAttributes(with: .clear)).width
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        textView.delegate = self
        contentMode = .topLeft
        addSubview(textView)
        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = CGRect(origin: CGPoint(x: lineNumberOffset + 10, y: 0), size: CGSize(width: frame.width - lineNumberOffset - 10, height: frame.height))
    }

    func textViewDidChange(_: UITextView) {
        setNeedsDisplay()
        updatedText()
    }

    func updatedText(buildAst: Bool = true) {
        let selectedRange = textView.selectedRange
        let oldFont = font
        if buildAst {
            let oldAst = currentAST
            let parser = Parser(string: textView.text)
            currentAST = parser.getAST()

            if let oldKernelDefinition = oldAst?.kernelDefinition(),
                let newKernelDefinition = currentAST?.kernelDefinition(),
                !(oldKernelDefinition.arguments == newKernelDefinition.arguments) {
                didUpdateArguments?(newKernelDefinition.arguments)
            }
        }
        textView.attributedText = currentAST?.asAttributedText
        textView.selectedRange = selectedRange
        textView.font = oldFont
        delegate?.textViewDidChange?(textView)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        var lineRange = NSMakeRange(0, 1)
        var index = 0
        var lineNumber = 1
        var shouldRenderLineNumber = true

        while index < textView.layoutManager.numberOfGlyphs {
            let lineRect = textView.layoutManager.lineFragmentUsedRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            lineRange = (textView.text as NSString).lineRange(for: lineRange)

            if draw(for: lineNumber, lineRange: lineRange, lineRect: lineRect, rect: rect, shouldRenderLineNumber: shouldRenderLineNumber) == false {
                return
            }

            shouldRenderLineNumber = textView.text[textView.text.index(textView.text.startIndex, offsetBy: index - 1)] == "\n"
            if shouldRenderLineNumber {
                lineNumber += 1
            }
        }
        lineRange = NSRange(location: textView.text.count, length: 0)
        draw(for: lineNumber, lineRange: lineRange, lineRect: textView.layoutManager.extraLineFragmentRect, rect: rect, shouldRenderLineNumber: shouldRenderLineNumber)
    }

    //: returns false if the current linerect is out of bounds
    @discardableResult
    func draw(for lineNumber: Int, lineRange: NSRange, lineRect: CGRect, rect: CGRect, shouldRenderLineNumber: Bool) -> Bool {
        let origin = CGPoint(x: 0, y: lineRect.origin.y - textView.contentOffset.y + textView.textContainerInset.top)

        if origin.y > frame.size.height {
            return false
        }

        if hightLightErrorLineNumber.contains(lineNumber) {
            fillLine(rect: CGRect(origin: origin, size: CGSize(width: rect.width, height: lineRect.height)), color: theme.sourceEditorLineBackgroundError)
        } else if textView.isFirstResponder && (lineRange.contains(textView.selectedRange.location) || lineRange.location == textView.selectedRange.location) && textView.selectedRange.length == 0 {
            fillLine(rect: CGRect(origin: origin, size: CGSize(width: rect.width, height: lineRect.height)), color: theme.sourceEditorLineBackgroundHighlighted)
        }

        if shouldRenderLineNumber && origin.y > -(textView.font?.lineHeight ?? 10) {
            draw(text: "\(lineNumber) ", at: origin, color: theme.sourceEditorLineNumber)
        }
        return true
    }

    func fillLine(rect: CGRect, color: UIColor) {
        color.setFill()
        UIGraphicsGetCurrentContext()?.fill(rect)
    }

    func lineNumberAttributes(with color: UIColor) -> [NSAttributedStringKey: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right

        return [
            .font: textView.font!,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
        ]
    }

    func draw(text: String, at point: CGPoint, color: UIColor) {
        (text as NSString).draw(in: CGRect(origin: point, size: CGSize(width: lineNumberOffset, height: font!.pointSize)), withAttributes: lineNumberAttributes(with: color))
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" && range.length == 0 {

            let firstString = (textView.text as NSString).substring(to: range.location)
            let currentTokenLocation = Parser(string: firstString).getTokens().count
            let intendationLevel = currentAST?.intendationLevel(at: currentTokenLocation, with: 0) ?? 0
            let tabs = Array(repeating: NumberedTextView.spacingValue, count: intendationLevel).joined()
            var newText = text + tabs

            let lastChrackterIsOpeningBracket = (textView.text as NSString).substring(with: NSMakeRange(range.location - 1, 1)) == "{"
            let newSelectedRange: NSRange

            if range.location < textView.text.characters.count && (textView.text as NSString).substring(with: NSMakeRange(range.location, 1)) == "}" && lastChrackterIsOpeningBracket {
                // {\n}
                newSelectedRange = NSMakeRange(range.location + newText.count + 1, 0)
                newText += "\(NumberedTextView.spacingValue)\n" + tabs
            } else if lastChrackterIsOpeningBracket && currentAST?.needsClosingBracket(at: currentTokenLocation) ?? false {
                // {\n
                newSelectedRange = NSMakeRange(range.location + newText.count, 0)
                let oldSpacing = Array(repeating: NumberedTextView.spacingValue, count: intendationLevel - 1).joined()
                newText += "\n\(oldSpacing)}"
            } else {
                newSelectedRange = NSMakeRange(range.location + newText.count, 0)
            }

            textView.text = textView.text.replacingCharacters(in: Range(range, in: textView.text)!, with: newText)
            textView.selectedRange = newSelectedRange
            updatedText()
            return false
        } else if text == "\t" && range.length == 0 {
            let newText = NumberedTextView.spacingValue
            textView.text = textView.text.replacingCharacters(in: Range(range, in: textView.text)!, with: newText)
            textView.selectedRange = NSMakeRange(range.location + newText.count, 0)
            return false
        }

        return true
    }

    func textViewDidChangeSelection(_: UITextView) {
        setNeedsDisplay()
    }

    func scrollViewDidScroll(_: UIScrollView) {
        setNeedsDisplay()
    }

    func insert(arguments: [(String, KernelAttributeType)]) {
        currentAST?.replaceArguments(newArguments: arguments)
        updatedText(buildAst: false)
    }
}
