//
//  SourceEditorTextStorage.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 23.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SourceEditorTextStorage: NSTextStorage {

    var shouldIgnoreNextChange = false
    var attribtutedStringForString: ((String, @escaping (NSAttributedString) -> Void) -> Void)?
    var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")

    override var string: String {
        return attributedString.string
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey: Any] {
        return attributedString.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        attributedString.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedStringKey: Any]?, range: NSRange) {
        attributedString.setAttributes(attrs, range: range)
    }

    override func processEditing() {
        super.processEditing()
        guard editedMask.contains(.editedCharacters) else { return }
        guard shouldIgnoreNextChange == false else { return }
        shouldIgnoreNextChange = false

        let nsstring = (string as NSString)
        let editedParagaphRange = nsstring.lineRange(for: editedRange)
        let editedParagraph = nsstring.substring(with: editedParagaphRange)

        attribtutedStringForString?(editedParagraph) { attributedParagraphString in
            self.beginEditing()
            attributedParagraphString.enumerateAttributes(in: NSMakeRange(0, attributedParagraphString.length), options: [], using: { attribute, currentRange, _ in
                var adjustedRange = NSMakeRange(editedParagaphRange.location + currentRange.location, currentRange.length)
                if adjustedRange.location + adjustedRange.length > self.string.count {
                    adjustedRange.length = self.string.count - adjustedRange.location
                } else if adjustedRange.length < 0 {
                    adjustedRange.length = 0
                }

                self.addAttributes(attribute, range: adjustedRange)
            })

            self.endEditing()
            self.edited(.editedAttributes, range: NSMakeRange(0, self.string.count), changeInLength: 0)
        }
    }
}
