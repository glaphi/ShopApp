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

    enum Configuration {
        static let scheme: String = "https"
        static let host: String = "mobile-code-challenge.s3.eu-central-1.amazonaws.com"
    }

    typealias HTTPHeader = [String : String]
    typealias HTTPMethod = String


    /// Get JSON object from network
    /// - Parameters:
    ///   - scheme: defaults to https
    ///   - host: defaults to mobile code challenge host
    ///   - path: api path
    ///   - headers: headers
    ///   - cachePolicy: request cache policy
    ///   - taskHandlingBlock:task handling block in case cancelation might be neede
    ///   - completion: request completion
    static func get<T: Decodable>(
        scheme: String = Configuration.scheme,
        host: String = Configuration.host,
        path: String,
        headers: [String : String],
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        taskHandlingBlock: ((URLSessionDataTask) -> ())? = nil,
        completion: @escaping (Result<T, Error>) -> ()
    ) {

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path

        guard let url = urlComponents.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        Network.get(
            requestURL: url,
            headers: headers,
            cachePolicy: cachePolicy,
            taskHandlingBlock: taskHandlingBlock) { result in

                switch result {
                case .success(let data):
                    do {
                        let decodedObject = try jsonDecoder.decode(T.self, from: data)
                        completion(.success(decodedObject))
                    } catch {
                        completion(.failure(error))
                    }

                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }


    /// Get some Data from network
    /// - Parameters:
    ///   - url: request URL
    ///   - headers: request headers
    ///   - cachePolicy: request cache policy
    ///   - taskHandlingBlock: task handling block in case cancelation might be neede
    ///   - completion: request completion
    static func get(
        requestURL: URL,
        headers: [String : String],
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
            success: { data in
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                completion(.success(data))
        },
            failure: { error in completion(.failure(error)) }
        )
    }

    private static func createTask(
        requestURL: URL,
        headers: [String: String],
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        httpMethod: String,
        taskHandlingBlock: ((URLSessionDataTask) -> ())? = nil,
        success: @escaping (Data?) -> (),
        failure: @escaping (Error) -> ()
    ) {

            let request: URLRequest =  URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: shorterTimeOut)

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

    private static let shorterTimeOut: TimeInterval = 30

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
