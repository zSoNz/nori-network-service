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

public class UrlSessionService: SessionService {
    
    public typealias DataType = Data?
    
    private static let session = URLSession.shared
    
    public static func dataTask(url: URL, completion: @escaping (DataType) -> ()) -> Task {
        let dataTask = self.session.dataTask(with: url) { data, _, _ in
            completion(data!)
        }
        
        let task = UrlSessionTask(task: dataTask)
        
        return task
    }
}

public class TaskExecutableDataHandler<ModelType> {
    
    public var handler: ModelHandler<ModelType>?
    public var task: Task?
    
    public init(handler: ModelHandler<ModelType>?, task: Task?) {
        self.handler = handler
        self.task = task
    }
}

public struct RequestParametrsQuery {
    
    public typealias Params = [String : String]
    
    public let params: Params?
    
    public init(params: Params?) {
        self.params = params
    }
}

public struct Request<ModelType>
    where ModelType: NetworkProcessable
{
    
    public let modelType: ModelType.Type
    public let url: URL
}
