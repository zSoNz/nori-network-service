//
//  Types.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

public typealias ModelHandler<Type> = (Type) -> ()

public typealias NetworkOperationComposingResult<DataType, ModelType> = (TaskExecutableDataHandler<DataType>, ModelType)

public protocol URLContainable {
    
    static var url: URL { get }
}

public protocol DataInitiable {
    
    typealias DataType = Data
}

public protocol NetworkModel: DataInitiable, Codable {
    
}

public protocol NetworkProcessable: URLContainable, NetworkModel where DataType == Data {
    
    associatedtype Service: SessionService where Service.DataType == DataType
    
    associatedtype ReturnedType: NetworkModel
    
    static func initialize(with data: Result<DataType, Error>) -> Result<ReturnedType, Error>
}

public protocol Task {
   
    func resume()
    func cancel()
}

public protocol SessionService {
    
    associatedtype DataType
    
    typealias ResultedDataType = Result<DataType, Error>
    typealias DataTypeHandler = (ResultedDataType) -> ()
    
    static func dataTask<ModelType: NetworkProcessable>(
        request: Request<ModelType>,
        completion: @escaping DataTypeHandler
    ) -> Task
}

public protocol Headers: Encodable {
    
    var dictionary: [String : String] { get }
}

public protocol QueryParamsType: Encodable { }

public protocol BodyParamsType: Encodable { }

public extension BodyParamsType {
    
    var contentType: String {
        return "application/json; charset=UTF-8"
    }
}

public struct File {
    
    let data: Data
    let mimeType: String
}
