//
//  RequestMetricsCollectionViewCell.swift
//  URLSessionMetrics
//
//  Created by Daniel Miedema on 6/16/16.
//  Copyright © 2016 dmiedema. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
/// Header view for use in the collection view
class RequestMetricsCollectionViewHeader: UICollectionReusableView {
    lazy var requestBaseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = .white
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        _ = [requestBaseLabel].map {
            addSubview($0)
        }
        self.addConstraints([
            requestBaseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            requestBaseLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            requestBaseLabel.topAnchor.constraint(equalTo: topAnchor),
            requestBaseLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

@available(iOS 10.0, *)
/// Collection View Cell for use in displaying the various URLSessionMetrics
class RequestMetricsCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    lazy var requestPathLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        return label
    }()

    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.regular)
        return label
    }()

    lazy var redirectsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        return label
    }()

    lazy var responseTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        _ = [requestPathLabel, durationLabel, redirectsCountLabel, responseTimeLabel].map {
            contentView.addSubview($0)
        }
        contentView.backgroundColor = .white
        contentView.addConstraints(requestPathLabelConstraints())
        contentView.addConstraints(durationLabelConstraints())
        contentView.addConstraints(redirectsCountLabelConstraints())
        contentView.addConstraints(responseTimeLabelConstraints())
        contentView.backgroundColor = .white
    }

    //MARK: - Methods
    func configure(metrics: URLSessionTaskMetrics) {
        requestPathLabel.text = metrics.requestURL?.url?.path ?? "Unknown Path"
        let duration = metrics.taskInterval.duration * 1000
        durationLabel.text = String(format: "Duration: %.2f ms", duration)
        redirectsCountLabel.text = "Redirects: \(metrics.redirectCount)"
        var totalResponseTime = 0.0
        for metric in metrics.transactionMetrics {
            guard let endTime = metric.responseEndDate?.timeIntervalSince1970,
                let startTime = metric.responseStartDate?.timeIntervalSince1970 else {
                    return
            }
            totalResponseTime += (endTime - startTime)
        }
        let responseTime = totalResponseTime * 1000
        responseTimeLabel.text = String(format: "Response Time: %.2f ms", responseTime)
    }

    //MARK: - NSLayoutConstraints
    func requestPathLabelConstraints() -> [NSLayoutConstraint] {
        return [
            requestPathLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            requestPathLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            requestPathLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ]
    }

    func durationLabelConstraints() -> [NSLayoutConstraint] {
        return [
            durationLabel.topAnchor.constraint(equalTo: requestPathLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: requestPathLabel.leadingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: requestPathLabel.trailingAnchor),
        ]
    }

    func redirectsCountLabelConstraints() -> [NSLayoutConstraint] {
        return [
            redirectsCountLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 4),
            redirectsCountLabel.leadingAnchor.constraint(equalTo: durationLabel.leadingAnchor),
            redirectsCountLabel.trailingAnchor.constraint(equalTo: durationLabel.trailingAnchor),
        ]
    }

    func responseTimeLabelConstraints() -> [NSLayoutConstraint] {
        return [
            responseTimeLabel.topAnchor.constraint(equalTo: redirectsCountLabel.bottomAnchor, constant: 4),
            responseTimeLabel.leadingAnchor.constraint(equalTo: redirectsCountLabel.leadingAnchor),
            responseTimeLabel.trailingAnchor.constraint(equalTo: redirectsCountLabel.trailingAnchor),
            responseTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ]
    }
}
