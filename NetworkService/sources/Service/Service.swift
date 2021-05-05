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

internal let EmptyTaskDataValue = Double.pi.description
internal class EmptyTask: Task {
    
    var completion: ModelHandler<Result<Data, Error>>?
    
    func resume() {
        guard let data = EmptyTaskDataValue.data(using: .utf8) else {
            return
        }
        
        self.completion?(.success(data))
    }
    
    func cancel() {
        
    }
}

final public class LocalSessionService: DataSessionService {
 
    public static func dataTask<ModelType>(
        request: Request<ModelType, LocalSessionService>,
        completion: @escaping DataTypeHandler
    )
        -> Task where ModelType : NetworkProcessable
    {
        let task = EmptyTask()
        
        task.completion = completion
        
        return task
    }
}

enum Constants: String {
    
    case boundary = "nori netwrok layer"
}

final public class UrlSessionService: DataSessionService {
    
    public static var headers: Headers = EmptyHeaders()
    
    private static let session = URLSession.shared
    
    public static func dataTask<ModelType>(
        request: Request<ModelType, UrlSessionService>, completion: @escaping DataTypeHandler
    )
        -> Task where ModelType : NetworkProcessable
    {
        let request = self.request(request: request)
        let dataTask = self.session.dataTask(with: request) { data, response, error in
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
    
    private static func request<ModelType: NetworkProcessable>(request: Request<ModelType, UrlSessionService>) -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
               
        headers.dictionary.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        switch request.type{
        case .post:
            urlRequest.httpMethod = "POST"
        case .put:
            urlRequest.httpMethod = "PUT"
        case .delete:
            urlRequest.httpMethod = "DELETE"
        default:
            break
        }
        
        if !(request.type == .get) {
            urlRequest.setValue("multipart/form-data; boundary=\(Constants.boundary.rawValue)", forHTTPHeaderField: "Content-type")
            urlRequest.httpBody = request.body
        }
        
        return urlRequest
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

public enum RequestType {
    
    case get
    case post
    case put
    case delete
}

public struct Request<ModelType, Service>
where ModelType: NetworkProcessable, Service: SessionService
{
    
    typealias Service = Service
    
    public let modelType: ModelType.Type
    public let url: URL
    public let body: Data?
    public let contentType: String
    
    internal var type = RequestType.get
    
    public init(
        modelType: ModelType.Type,
        url: URL,
        body: Data? = nil,
        contentType: String = ""
    ) {
        self.modelType = modelType
        self.url = url
        self.body = body
        self.contentType = contentType
    }
}
