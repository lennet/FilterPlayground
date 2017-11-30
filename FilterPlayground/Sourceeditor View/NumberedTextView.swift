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

    let textView: SourceEditorTextView = {
        let textView = SourceEditorTextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.autoresizingMask = UIViewAutoresizing.flexibleHeight.union(.flexibleWidth)
        (textView as UIScrollView).delaysContentTouches = false
        return textView
    }()

    weak var delegate: UITextViewDelegate?

    var didUpdateArguments: (([(String, KernelArgumentType)]) -> Void)?

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

    var highLightErrorLineNumber: Set<Int> = [] {
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
        textView.attribtutedStringForString = { text, resultCallback in
            DispatchQueue.global(qos: .userInteractive).async {
                let parser = Parser(string: text)
                let result = parser.getAST().asAttributedText
                DispatchQueue.main.async {
                    resultCallback(result)
                }
            }
        }

        textView.codeCompletionsForString = { text, location, resultCallback in
            DispatchQueue.global(qos: .userInteractive).async {
                let firstString = (text as NSString).substring(to: location)
                let currentTokenLocation = Parser(string: firstString).getTokens().count

                let parser = Parser(string: text)
                let result = parser.getAST().codeCompletion(at: currentTokenLocation, with: CIKernelLanguageHelper.functions)
                DispatchQueue.main.async {
                    resultCallback(result)
                }
            }
            //            resultCallback(["{", "}", "mod", "destCoord()", ";", "(", ")"])
        }
        contentMode = .topLeft
        addSubview(textView)
        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = CGRect(origin: CGPoint(x: lineNumberOffset + 10, y: 0), size: CGSize(width: frame.width - lineNumberOffset - 10, height: frame.height))
    }

    func textViewDidChange(_: UITextView) {
        delegate?.textViewDidChange?(textView)
        setNeedsDisplay()
        updatedText()
    }

    func hightlight(text: String) -> NSAttributedString {
        let parser = Parser(string: text)
        return parser.getAST().asAttributedText
    }

    func updatedText(buildAst: Bool = true) {
        let selectedRange = textView.selectedRange
        if buildAst,
            let text = self.textView.text {
            DispatchQueue.global(qos: .userInitiated).async {
                let oldAst = self.currentAST
                let parser = Parser(string: text)
                self.currentAST = parser.getAST()
                DispatchQueue.main.sync {
                    if let oldKernelDefinition = oldAst?.kernelDefinition(),
                        let newKernelDefinition = self.currentAST?.kernelDefinition(),
                        !(oldKernelDefinition.arguments == newKernelDefinition.arguments) {
                        self.didUpdateArguments?(newKernelDefinition.arguments)
                    }
                }
            }
        } else {
            textView.selectedRange = selectedRange
            delegate?.textViewDidChange?(textView)
        }
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

        if highLightErrorLineNumber.contains(lineNumber) {
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
            let tabs = Array(repeating: Settings.spacingValue, count: intendationLevel).joined()
            var newText = text + tabs

            let lastChrackterIsOpeningBracket = (textView.text as NSString).substring(with: NSMakeRange(range.location - 1, 1)) == "{"
            let newSelectedRange: NSRange

            if range.location < textView.text.count && (textView.text as NSString).substring(with: NSMakeRange(range.location, 1)) == "}" && lastChrackterIsOpeningBracket {
                // {\n}
                newSelectedRange = NSMakeRange(range.location + newText.count + 1, 0)
                newText += "\(Settings.spacingValue)\n" + tabs
            } else if lastChrackterIsOpeningBracket && currentAST?.needsClosingBracket(at: currentTokenLocation) ?? false {
                // {\n
                newSelectedRange = NSMakeRange(range.location + newText.count, 0)
                let oldSpacing = Array(repeating: Settings.spacingValue, count: intendationLevel - 1).joined()
                newText += "\n\(oldSpacing)}"
            } else {
                newSelectedRange = NSMakeRange(range.location + newText.count, 0)
            }

            textView.text = textView.text.replacingCharacters(in: Range(range, in: textView.text)!, with: newText)
            textView.selectedRange = newSelectedRange
            updatedText()
            return false
        } else if text == "\t" && range.length == 0 {
            let newText = Settings.spacingValue
            textView.text = textView.text.replacingCharacters(in: Range(range, in: textView.text)!, with: newText)
            textView.selectedRange = NSMakeRange(range.location + newText.count, 0)
            updatedText()
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

    func insert(arguments: [(String, KernelArgumentType)]) {
        let selectedRange = textView.selectedRange
        DispatchQueue.global(qos: .userInitiated).async {
            self.currentAST?.replaceArguments(newArguments: arguments)
            let newAttribtuedText = self.currentAST?.asAttributedText
            DispatchQueue.main.async {
                self.textView.attributedText = newAttribtuedText
                self.textView.selectedRange = selectedRange
                self.delegate?.textViewDidChange?(self.textView)
            }
        }
    }
}
