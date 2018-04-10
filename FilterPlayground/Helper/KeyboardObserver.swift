//
//  KeyboardObserver.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

struct KeyboardNotificationObject {
    var frameEnd: CGRect
    var frameBegin: CGRect

    fileprivate init(infoDict: [AnyHashable: Any]?) {
        frameEnd = (infoDict![UIKeyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
        frameBegin = (infoDict![UIKeyboardFrameBeginUserInfoKey] as? NSValue)!.cgRectValue
    }
}

enum KeyboardEvent {
    case willShow
    case willHide
}

class KeyboardObserver {
    typealias KeyboardObserverCallback = (KeyboardEvent, KeyboardNotificationObject) -> Void

    var callback: KeyboardObserverCallback
    var isKeyboardVisible: Bool = false

    init(callback: @escaping KeyboardObserverCallback) {
        self.callback = callback
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    func startObserving() {
        registerNotifications()
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        let notificationObject = KeyboardNotificationObject(infoDict: notification.userInfo)
        isKeyboardVisible = true
        callback(.willShow, notificationObject)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        let notificationObject = KeyboardNotificationObject(infoDict: notification.userInfo)
        isKeyboardVisible = false
        callback(.willHide, notificationObject)
    }
}
