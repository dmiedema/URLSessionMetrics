//
//  RequestManager.swift
//  URLSessionMetrics
//
//  Created by Daniel Miedema on 6/16/16.
//  Copyright © 2016 dmiedema. All rights reserved.
//

import Foundation
import URLSessionMetrics

public struct RequestBuilder {
    public enum Method: String {
        case GET  = "GET"
        case POST = "POST"
    }

    public let method: Method
    public let baseURL: String
    public let path: String?

    public var url: URL? {
        return URL(string: baseURL + (path ?? ""))
    }

    public var request: URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        return request
    }

    public static func build(method: Method, baseURL: String, path: String?) -> RequestBuilder {
        return RequestBuilder(method: method, baseURL: baseURL, path: path)
    }
    public static func build(method: Method, baseURL: String) -> RequestBuilder {
        return RequestBuilder(method: method, baseURL: baseURL, path: nil)
    }
}

public class RequestManager: NSObject {
    public static var session: URLSession {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: RequestManager(), delegateQueue: OperationQueue.main)

        return session
    }

    public class func send(request: URLRequest, completion: ((Data?, URLResponse?, NSError?) -> Void)?) {
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let completion = completion else { return }
            DispatchQueue.main.async {
                completion(data, response, error as NSError?)
            }
        }
        task.resume()
    }
}

extension RequestManager: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        NSLog("Finished collecting metrics")
        DefaultMetricsManager.shared.add(entry: metrics)
    }
}
