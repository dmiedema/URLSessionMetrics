//
//  RequestMetricsDetailView.swift
//  URLSessionMetrics
//
//  Created by Daniel Miedema on 6/16/16.
//  Copyright © 2016 dmiedema. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
extension URLSessionTaskMetrics.ResourceFetchType {
    /// Display string for the resource fetch type
    var displayString: String {
        switch self {
        case .localCache:
            return "Local Cache"
        case .networkLoad:
            return "Network Load"
        case .serverPush:
            return "Server Push"
        case .unknown:
            return "Unknown"
        }
    }
}
@available(iOS 10.0, *)
extension URLSessionTaskTransactionMetrics {
    /// Get the total time it took to connect.
    /// Will be `nil` if `connectStartDate` or `connectEndDate` were `nil`
    var connectTime: TimeInterval? {
        guard let connectEndDate = connectEndDate,
            let connectStartDate = connectStartDate else {
                return nil
        }
        return (connectEndDate.timeIntervalSince1970 - connectStartDate.timeIntervalSince1970) * 1000
    }

    /// Get the total time it took to do the domain lookup.
    /// Will be `nil` if `domainLookupStartDate` or `domainLookupEndDate` were `nil`
    var domainLookupTime: TimeInterval? {
        guard let domainLookupEndDate = domainLookupEndDate,
            let domainLookupStartDate = domainLookupStartDate else {
            return nil
        }
        return (domainLookupEndDate.timeIntervalSince1970 - domainLookupStartDate.timeIntervalSince1970) * 1000
    }

    /// Get the total time it took to do the request.
    /// Will be `nil` if `requestStartDate` or `requestEndDate` were `nil`
    var requestTime: TimeInterval? {
        guard let requestEndDate = requestEndDate,
            let requestStartDate = requestStartDate else {
                return nil
        }
        return (requestEndDate.timeIntervalSince1970 - requestStartDate.timeIntervalSince1970) * 1000
    }

    /// Get the total time it took to get the response.
    /// Will be `nil` if `responseStartDate` or `responseEndDate` were `nil`
    var responseTime: TimeInterval? {
        guard let responseEndDate = responseEndDate,
            let responseStartDate = responseStartDate else {
                return nil
        }
        return (responseEndDate.timeIntervalSince1970 - responseStartDate.timeIntervalSince1970) * 1000
    }

    /// Get the total time it took to create a secure connection.
    /// Will be `nil` if `secureConnectionStartDate` or `secureConnectionEndDate` were `nil`
    var secureConnectionTime: TimeInterval? {
        guard let secureConnectionEndDate = secureConnectionEndDate,
            let secureConnectionStartDate = secureConnectionStartDate else {
                return nil
        }
        return (secureConnectionEndDate.timeIntervalSince1970 - secureConnectionStartDate.timeIntervalSince1970) * 1000
    }
}

@available(iOS 10.0, *)
class RequestTransactionMetricsDetailView: UIView {
    let transactionMetric: URLSessionTaskTransactionMetrics
    init(transactionMetric: URLSessionTaskTransactionMetrics) {
        self.transactionMetric = transactionMetric
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        viewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createLabel(text: String?, monospaced: Bool) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text ?? ""
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        if monospaced {
            label.font = .monospacedLabelFont
        }
        return label
    }
    func viewSetup() {
        // request url
        let requestURL = transactionMetric.request.url
        let requestURLLabel = createLabel(text: (requestURL?.host ?? "") + (requestURL?.path ?? ""), monospaced: false)
        // request headers
        var headerText: String = ""
        if let headers = transactionMetric.request.allHTTPHeaderFields {
            for (_, key) in headers.keys.enumerated() {
                headerText.append("\(key): \(headers[key]!)\n")
            }
        }
        let requestHeaders = createLabel(text: headerText, monospaced: true)

        // request method
        let requestMethod = createLabel(text: transactionMetric.request.httpMethod, monospaced: true)
        // request parameters
        let requestParameters = createLabel(text: requestURL?.query, monospaced: false)

        // Fetched From
        let fetchedFrom =  createLabel(text: "Fetched From: \(transactionMetric.resourceFetchType.displayString)", monospaced: false)

        // response Mime
        let response = transactionMetric.response
        let responseHeaders = createLabel(text: response?.mimeType, monospaced: true)
        // response length
        let responseLength = createLabel(text: "Expected Length: \(response?.expectedContentLength ?? 0)", monospaced: false)
        // repsonse encoding
        let responseEncoding = createLabel(text: response?.textEncodingName, monospaced: true)

        // is proxy
        let isProxy = createLabel(text: transactionMetric.isProxyConnection ? "Proxied" : nil, monospaced: false)
        // is reused
        let isReused = createLabel(text: transactionMetric.isReusedConnection ? "Reused Connection" : nil, monospaced: false)
        // connection time
        let connectionTime = createLabel(text: String(format: "Connection Time: %.2f ms", transactionMetric.connectTime ?? 0), monospaced: true)
        // dns lookup time
        let domainLookupTime = createLabel(text: String(format: "Domain Lookup: %.2f ms", transactionMetric.domainLookupTime ?? 0), monospaced: true)
        // secure connection time
        let secureConnectionTime = createLabel(text: String(format: "Secure Connection Time: %.2f ms", transactionMetric.secureConnectionTime ?? 0), monospaced: true)
        // request time
        let requestTime = createLabel(text: String(format: "Request Time: %.2f ms", transactionMetric.requestTime ?? 0), monospaced: true)
        // response time
        let responseTime = createLabel(text: String(format: "Response Time: %.2f ms", transactionMetric.responseTime ?? 0), monospaced: true)

        let labels = [requestURLLabel, requestHeaders, requestMethod, requestParameters, fetchedFrom, responseHeaders, responseLength, responseEncoding, isProxy, isReused, connectionTime, domainLookupTime, secureConnectionTime, requestTime, responseTime]

        // Super hacky way to add constraints.
        for (index, label) in labels.enumerated() {
            self.addSubview(label)
            // first element
            if index == 0 {
                self.addConstraints([
                    label.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
                    ])
                continue
            }
            let prevousLabel = labels[index - 1]
            self.addConstraints([
                label.leadingAnchor.constraint(equalTo: prevousLabel.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: prevousLabel.trailingAnchor),
                label.topAnchor.constraint(equalTo: prevousLabel.bottomAnchor, constant: 4)
                ])
        }

        guard let first = labels.first,
            let last = labels.last else {
                fatalError("No First/last labels found") }

        self.addConstraints([
            first.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            last.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            ])
    }
}

@available(iOS 10.0, *)
class RequestMetricsDetailView: UIViewController {
    //MARK: - Properties
    let metrics: URLSessionTaskMetrics

    //MARK: - Creation
    init(metrics: URLSessionTaskMetrics) {
        self.metrics = metrics
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard metrics.transactionMetrics.count > 0 else {
            return
        }
        var subviews = [RequestTransactionMetricsDetailView]()
        for transactionMetric in metrics.transactionMetrics {
            subviews.append(RequestTransactionMetricsDetailView(transactionMetric: transactionMetric))
        }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = false
        view.addSubview(scrollView)
        view.addConstraints([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.size.width)
            ])

        for (index, subview) in subviews.enumerated() {
            subview.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(subview)

            if index == 0 {
                scrollView.addConstraints([
                    subview.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
                    subview.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
                ])
                continue
            }
            let previousView = subviews[index - 1]
            scrollView.addConstraints([
                subview.leadingAnchor.constraint(equalTo: previousView.leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: previousView.trailingAnchor),
                subview.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor),
                subview.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 4),
                ])
        }

        guard let first = subviews.first,
            let last = subviews.last else {
                fatalError("No first/last subviews") }

        scrollView.addConstraints([
            first.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            last.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            ])
    }
}
