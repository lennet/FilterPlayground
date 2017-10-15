//
//  DataBindingContext.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class DataBindingContext {

    static let shared = DataBindingContext()

    private init() {}

    private var observers: [String: DataBindingObserver] = [:]

    func add(observer: DataBindingObserver, with name: String) {
        observers[name] = observer
    }

    func removeObserver(with name: String) {
        observers.removeValue(forKey: name)
    }

    func observer(with name: String) -> DataBindingObserver? {
        return observers[name]
    }

    func emit(value: Any, for dataBinding: DataBinding) {
        notifyObservers(for: dataBinding, with: value)
    }

    func notifyObservers(for type: DataBinding, with value: Any) {
        for observer in observers.values where observer.observedBinding.self == type {
            observer.valueChanged(value: value)
        }
    }

    func reset() {
        observers.removeAll()
    }
}
