//
//  RequestMetrics.swift
//  URLSessionMetrics
//
//  Created by Daniel Miedema on 6/16/16.
//  Copyright © 2016 dmiedema. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
/// MetricsManager protocol.
public protocol MetricsManager {
    /// Shared/Static instance of the metrics manager
    static var shared: MetricsManager { get }

    /// Array of `URLSessionTaskMetrics`
    var metrics: [URLSessionTaskMetrics] { get }

    /// Method to add a set of `URLSessionTaskMetrics`
    func add(entry: URLSessionTaskMetrics)
}

/// Default Metrics Manager instance
public class DefaultMetricsManager: NSObject, MetricsManager {
    public static var shared: MetricsManager = DefaultMetricsManager()

    public lazy var metrics: [URLSessionTaskMetrics] = {
        return []
    }()

    public func add(entry: URLSessionTaskMetrics) {
        metrics.append(entry)
    }
}

@available(iOS 10.0, *)
/// Helpers for `URLSessionTaskMetrics`
public extension URLSessionTaskMetrics {
    /// [DEPRICATED] details strin
    var details: String {
        return "Duration: \(self.taskInterval.duration)"
        + "\n" +
        "Redirect Count: \(self.redirectCount)"
    }
    
    /// Get the first request URL. Useful for extracting various information about
    /// the subsiquent requests.
    /// - returns: first transaction metrics request or `nil` if there is not one.
    public var requestURL: URLRequest? {
        return self.transactionMetrics.first?.request
    }
}
