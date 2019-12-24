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

    static func get<T: Decodable>(
        path: String,
        headers: HTTPHeader,
        taskHandlingBlock: ((URLSessionDataTask) -> ())? = nil,
        completion: @escaping (Result<T, Error>) -> ()
    ) {

        print("path is ", path)

        Network.createTask(
            path: path,
            headers: headers,
            httpMethod: HTTPMethod.get,
            taskHandlingBlock: taskHandlingBlock,
            success: { data in
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                    print("Data as json: ", JSONString)
                }

                do {
                    let decodedObject = try jsonDecoder.decode(T.self, from: data)
                    print("decoded data")
                    completion(.success(decodedObject))
                } catch {
                    print("dailed to decode")
                    completion(.failure(error))
                }

        },
            failure: { error in completion(.failure(error)) }
        )
    }

    /// Create URL session data task with autorization header request
    private static func createTask(
        path: String,
        headers: [String: String],
        httpMethod: String,
        taskHandlingBlock: ((URLSessionDataTask) -> ())? = nil,
        success: @escaping (Data?) -> (),
        failure: @escaping (Error) -> ()
    ) {

        do {
            let request: URLRequest = try URLRequest.init(path)

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

        } catch {
            failure(error)
        }
    }

    private static let urlSession = URLSession(configuration: .default)
}

extension Network.HTTPHeader {
    static let acceptJson: Network.HTTPHeader = ["Accept" : "application/json"]
}

extension Network.HTTPMethod {
    static let get: Network.HTTPMethod = "GET"
}

fileprivate extension URLRequest {

    init(_ path: String) throws {
        var urlComponents = URLComponents()
        urlComponents.scheme = Network.Configuration.scheme
        urlComponents.host = Network.Configuration.host
        urlComponents.path = path

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        self = URLRequest(
            url: url,
            cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, // default
            timeoutInterval: 30 // default is 60 seconds
        )
    }

}

fileprivate extension HTTPURLResponse {

    var isSuccessful: Bool {
        200 ..< 300 ~= statusCode
    }

}
