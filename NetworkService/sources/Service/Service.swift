//
//  Service.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

public class UrlSessionTask: Task {
    
    private let task: URLSessionDataTask
    
    public init(task: URLSessionDataTask) {
        self.task = task
    }
    
    public func resume() {
        self.task.resume()
    }
    
    public func cancel() {
        self.task.cancel()
    }
}

public enum UrlSessionServiceError: Error {
    
    case unknown
}

private let erorrsStatusCodes = (400...599)

public struct EmptyHeaders: Headers { }

public class UrlSessionService: SessionService {
    
    public typealias DataType = Data
    
    public static var headers: Headers = EmptyHeaders()
    
    private static let session = URLSession.shared
    
    public static func dataTask(url: URL, completion: @escaping DataTypeHandler) -> Task {
        let dataTask = self.session.dataTask(with: self.request(url: url)) { data, response, error in
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, let result = data {
                if erorrsStatusCodes.contains(statusCode) {
                    completion(.failure(decodeResponseError(statusCode: statusCode, data: result)))
                    
                    return
                }
            }
            
            let result: ResultedDataType = data.map { .success($0) }
                ?? error.map { .failure($0) }
                ?? .failure(UrlSessionServiceError.unknown)
            
            completion(result)
        }
        
        let task = UrlSessionTask(task: dataTask)
        
        return task
    }
    
    private static func request(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
               
        headers.dictionary.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return request
    }
}

public class TaskExecutableDataHandler<ModelType> {
    
    public typealias ModelTypeHandler = ModelHandler<Result<ModelType, Error>>
    
    public var handler: ModelTypeHandler?
    public var task: Task?
    
    public init(handler: ModelTypeHandler?, task: Task?) {
        self.handler = handler
        self.task = task
    }
}

public struct Request<ModelType>
    where ModelType: NetworkProcessable
{
    
    public let modelType: ModelType.Type
    public let url: URL
}
