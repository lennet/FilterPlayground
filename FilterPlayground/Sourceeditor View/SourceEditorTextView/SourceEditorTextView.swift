//
//  SourceEditorTextView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 19.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SourceEditorTextView: UITextView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSTextStorageDelegate {
    
    var attribtutedStringForString: ((String, @escaping (NSAttributedString) -> ()) -> ())?{
        set {
            (textStorage as? SourceEditorTextStorage)?.attribtutedStringForString = newValue
        }
        get {
            return (textStorage as? SourceEditorTextStorage)?.attribtutedStringForString
        }
    }
    
    fileprivate var cachedCodeCompletions: [String] = [] {
        didSet {
            if oldValue != cachedCodeCompletions {
                codeCompletionColectionView.reloadData()
            }
        }
    }
    var codeCompletionsForString: ((String, Int, @escaping ([String]) -> ()) -> ())?
    
    let codeCompletionColectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let initialFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 64))
        let collectionView = UICollectionView(frame: initialFrame, collectionViewLayout: layout)
        return collectionView
    }()
    
    init(frame: CGRect) {
        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        let storage = SourceEditorTextStorage()
        storage.addLayoutManager(layoutManager)
        super.init(frame: frame, textContainer: textContainer)
        storage.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        configureCodeCompletionView()
    }
    
    override var selectedTextRange: UITextRange? {
        didSet {
            codeCompletionsForString?(text, selectedRange.location) { result in
                self.cachedCodeCompletions = result
            }
        }
    }
    
    // MARK: - NSTextStorageDelegate
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        codeCompletionsForString?(text, selectedRange.location) { result in
            self.cachedCodeCompletions = result
        }
    }
    
    // MARK: - Code Completion
    
    func configureCodeCompletionView() {
        let view = codeCompletionColectionView
        view.delegate = self
        view.dataSource = self
        view.register(CodeCompletionCollectionViewCell.self, forCellWithReuseIdentifier: CodeCompletionCollectionViewCell.reuseIdentifier)
        view.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0.8352941176, blue: 0.8588235294, alpha: 1)
        inputAccessoryView = view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = (collectionView.frame.width - collectionView.intrinsicContentSize.width)/3
        return UIEdgeInsetsMake(0, insets, 0, insets)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cachedCodeCompletions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = cachedCodeCompletions[indexPath.item]
        
        while let lastChar = (text as NSString).substring(to: selectedRange.location).last,
            let unicodeScalar = lastChar.unicodeScalars.first,
            NSCharacterSet.letters.contains(unicodeScalar) {
            deleteBackward()
        }
        insertText(selectedItem)
        insertText(" ")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let string = cachedCodeCompletions[indexPath.row] as NSString
        // TODO adjust font with dynamic type traits
        let font = UIFont.systemFont(ofSize: 17)
        let width = string.size(withAttributes: [.font: font]).width + 20
        return CGSize(width: width, height: 54)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CodeCompletionCollectionViewCell.reuseIdentifier, for: indexPath) as! CodeCompletionCollectionViewCell
        cell.text = cachedCodeCompletions[indexPath.row]
        cell.contentView.backgroundColor = .lightGray
        cell.contentView.layer.cornerRadius = 6
        cell.contentView.layer.masksToBounds = true
        return cell
    }

}
