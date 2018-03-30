//
//  FeatureGate.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 20.12.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class FeatureGate {
    static func isEnabled(feature _: ExperimentalFeature) -> Bool {
        // we pass the feature as an argument to get an error after removing the experimental feature from the enum
        #if DEBUG
            return Settings.enableExperimentalFeatures
        #else
            return false
        #endif
    }
}
