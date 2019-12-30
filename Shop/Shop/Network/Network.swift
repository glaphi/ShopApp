//
//  Network.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation

// MARK: - Network with more generic implementation

class Network {

    typealias HTTPHeader = [String : String]
    typealias HTTPMethod = String

    /// Get data from network
    /// - Parameters:
    ///   - url: request URL
    ///   - headers: request headers
    ///   - cachePolicy: request cache policy
    ///   - taskHandlingBlock: task handling block in case cancelation might be neede
    ///   - completion: request completion
    static func get(
        requestURL: URL,
        headers: Network.HTTPHeader,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        taskHandlingBlock: ((URLSessionDataTask) -> ())? = nil,
        completion: @escaping (Result<Data, Error>) -> ()
    ) {

        Network.createTask(
            requestURL: requestURL,
            headers: headers,
            cachePolicy: cachePolicy,
            httpMethod: HTTPMethod.get,
            taskHandlingBlock: taskHandlingBlock,
            failure: { error in
                completion(.failure(error))
        },
            success: { data in
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            completion(.success(data))
        })
    }

    private static func createTask(
        requestURL: URL,
        headers: Network.HTTPHeader,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        httpMethod: Network.HTTPMethod,
        taskHandlingBlock: ((URLSessionDataTask) -> ())? = nil,
        failure: @escaping (Error) -> (),
        success: @escaping (Data?) -> ()
    ) {

            let request: URLRequest =  URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: customTimeoutInterval)

            let task = urlSession.dataTask(with: request) { (data, response, error) in

                guard error == nil else {
                    return failure(error!)
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    return failure(URLError(.cannotParseResponse))
                }
                guard httpResponse.isSuccessful else {
                    return failure(URLError(.badServerResponse))
                }

                success(data)
            }

            taskHandlingBlock?(task)

            task.resume()
    }

    private static let customTimeoutInterval: TimeInterval = 30

    private static let urlSession = URLSession(configuration: .default)
}

extension Network.HTTPHeader {
    static let acceptJson: Network.HTTPHeader = ["Accept" : "application/json"]
    static let acceptImage: Network.HTTPHeader = ["Accept" : "image/*"]
}

extension Network.HTTPMethod {
    static let get: Network.HTTPMethod = "GET"
}

fileprivate extension HTTPURLResponse {

    var isSuccessful: Bool {
        200 ..< 300 ~= statusCode
    }

}
