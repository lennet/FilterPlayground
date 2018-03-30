//
//  StatisticsView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 22.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class StatisticsView: UIView {
    private let frameRateLabel = UILabel()
    private let timeLabel = UILabel()
    private let stackView = UIStackView()

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        stackView.frame = bounds
        stackView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        stackView.addArrangedSubview(frameRateLabel)
        stackView.addArrangedSubview(timeLabel)
        addSubview(stackView)
    }

    func updateStatistics(frameRate: Double, time: Double) {
        DispatchQueue.main.async {
            // TODO: add spacing
            self.frameRateLabel.text = 🌎("Statistics_FPS_Label_$f", with: frameRate)
            self.timeLabel.text = 🌎("Statistics_GPU_Label_$f", with: time * 1000)
        }
    }
}
