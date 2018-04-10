//
//  Identifiable.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

protocol Identifiable {}
extension Identifiable {
    static var identifier: String {
        return String(describing: self) + "Identifier"
    }
}

extension UIStoryboard {
    func instantiate<T>(viewController: T.Type) -> T where T: Identifiable, T: UIViewController {
        return instantiateViewController(withIdentifier: viewController.identifier) as! T
    }
}
