//
//  Operators.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

public typealias ModelHandlerType<ModelType: NetworkProcessable>
    = ModelHandler<Result<ModelType.ReturnedType, Error>>

public typealias HTTPMethod<ModelType: NetworkProcessable, ServiceType>
    = (Request<ModelType>) -> Task?

@discardableResult
public func get <ModelType: NetworkProcessable, ServiceType>(
    modelHandler: @escaping ModelHandlerType<ModelType>
)
    -> ((Request<ModelType>) -> Task?) where ModelType.Service == ServiceType
{
    lift(modelHandler: modelHandler, requestType: .get)
}

@discardableResult
public func post <ModelType: NetworkProcessable, ServiceType>(
    modelHandler: @escaping ModelHandlerType<ModelType>
)
    -> ((Request<ModelType>) -> Task?) where ModelType.Service == ServiceType
{
    lift(modelHandler: modelHandler, requestType: .post)
}

@discardableResult
public func del <ModelType: NetworkProcessable, ServiceType>(
    modelHandler: @escaping ModelHandlerType<ModelType>
)
    -> ((Request<ModelType>) -> Task?) where ModelType.Service == ServiceType
{
    lift(modelHandler: modelHandler, requestType: .delete)
}

@discardableResult
public func put <ModelType: NetworkProcessable, ServiceType>(
    modelHandler: @escaping ModelHandlerType<ModelType>
)
    -> ((Request<ModelType>) -> Task?) where ModelType.Service == ServiceType
{
    
    lift(modelHandler: modelHandler, requestType: .put)
}

private func lift <ModelType: NetworkProcessable, ServiceType>(
    modelHandler: @escaping ModelHandlerType<ModelType>,
    requestType: RequestType
)
    -> ((Request<ModelType>) -> Task?) where ModelType.Service == ServiceType
{
    curry(flip(task))(requestType)(modelHandler)
}

private func task<ModelType: NetworkProcessable, ServiceType>(
    request: Request<ModelType>,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>,
    requestType: RequestType
) -> Task?
     where ServiceType == ModelType.Service
{
    var mutable = request
    
    mutable.type = requestType
    
    let data = (ServiceType.self |+| mutable)
    
    data.0.handler = { result in
        modelHandler(ModelType.initialize(with: result))
    }
    
    data.0.task?.resume()
    
    return data.0.task
}

/// Combine model/request/params with service
infix operator |+|: MultiplicationPrecedence
@discardableResult
public func |+| <Session: SessionService, Model: NetworkProcessable> (
    session: Session.Type,
    request: Request<Model>
)
    -> NetworkOperationComposingResult<Model.DataType, Model.Type> where Session.DataType == Model.DataType
{
    let handlerContainer = TaskExecutableDataHandler<Model.DataType>(handler: nil, task: nil)
    
    let task = session.dataTask(request: request) {
        handlerContainer.handler?($0)
    }
    
    handlerContainer.task = task
    
    return (handlerContainer, Model.self)
}

public func |+| <ModelType, Params: QueryParamsType>(model: ModelType.Type, params: Params) -> Request<ModelType>
    where ModelType: NetworkProcessable
{
    let encoder = JSONEncoder()
    let data = (try? encoder.encode(params)) ?? Data()
    
    let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String : Any]
    
    let url = model.url +? (dictionary ?? [:])
    
    return Request(modelType: model, url: url)
}

public func |+| <ModelType, Params: BodyParamsType>(model: ModelType.Type, params: Params) -> Request<ModelType>
    where ModelType: NetworkProcessable
{
    let encoder = JSONEncoder()
    
    let data = (try? encoder.encode(params)) ?? Data()
    
    var dictionary = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String : Any]
    dictionary?.merge(params.rawValues) { (_, new) in new }
    
    let encoded = dictionary?.multipartRequestConverted() ?? Data()
    
    let url = model.url
    
    return Request(modelType: model, url: url, body: encoded)
}

public typealias HTTPCombineResult<ModelType: NetworkProcessable>
    = (@escaping (Result<ModelType.ReturnedType, Error>) -> ()) -> Task?

/// Combine request with http method
infix operator |*|: AdditionPrecedence

@discardableResult
public func |*| <ModelType, ServiceType>(
    request: Request<ModelType>,
    method: @escaping HTTPMethod<ModelType, ServiceType>
)
    -> Task? where ModelType.Service == ServiceType
{
    return method(request)
}

@discardableResult
public func |*| <ModelType: NetworkProcessable, ServiceType> (
    model: ModelType.Type,
    method: @escaping HTTPMethod<ModelType, ServiceType>
)
    -> Task? where ModelType.Service == ServiceType
{
    let request = Request<ModelType>(modelType: model, url: model.url)
    return method(request)
}
