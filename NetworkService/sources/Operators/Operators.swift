//
//  Operators.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

infix operator <=|: DefaultPrecedence // GET
infix operator |=>: DefaultPrecedence // POST
infix operator !=>: DefaultPrecedence // DEL
infix operator =>>: DefaultPrecedence // PUT

@discardableResult
public func <=| <ModelType: NetworkProcessable, ServiceType>(
    request: Request<ModelType>,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>
) -> Task?
    where ModelType.Service == ServiceType
{
    return task(request: request, modelHandler: modelHandler, requestType: .get)
}

@discardableResult
public func <=| <ModelType: NetworkProcessable, ServiceType>(
    model: ModelType.Type,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>
) -> Task?
    where ServiceType == ModelType.Service
{
    return Request<ModelType>(modelType: model, url: model.url) <=| modelHandler
}

@discardableResult
public func |=> <ModelType: NetworkProcessable, ServiceType>(
    request: Request<ModelType>,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>
) -> Task?
    where ModelType.Service == ServiceType
{
    return task(request: request, modelHandler: modelHandler, requestType: .post)
}

@discardableResult
public func |=> <ModelType: NetworkProcessable, ServiceType>(
    model: ModelType.Type,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>
) -> Task?
    where ServiceType == ModelType.Service
{
    return Request<ModelType>(modelType: model, url: model.url) |=> modelHandler
}

@discardableResult
public func =>> <ModelType: NetworkProcessable, ServiceType>(
    request: Request<ModelType>,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>
) -> Task?
    where ModelType.Service == ServiceType
{
    return task(request: request, modelHandler: modelHandler, requestType: .put)
}

@discardableResult
public func =>> <ModelType: NetworkProcessable, ServiceType>(
    model: ModelType.Type,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>
) -> Task?
    where ServiceType == ModelType.Service
{
    return Request<ModelType>(modelType: model, url: model.url) =>> modelHandler
}

@discardableResult
public func !=> <ModelType: NetworkProcessable, ServiceType>(
    request: Request<ModelType>,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>
) -> Task?
    where ModelType.Service == ServiceType
{
    return task(request: request, modelHandler: modelHandler, requestType: .delete)
}

@discardableResult
public func !=> <ModelType: NetworkProcessable, ServiceType>(
    model: ModelType.Type,
    modelHandler: @escaping ModelHandler<Result<ModelType.ReturnedType, Error>>
) -> Task?
    where ServiceType == ModelType.Service
{
    return Request<ModelType>(modelType: model, url: model.url) !=> modelHandler
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
    
    let data = (ServiceType.self *| mutable)
    
    data.0.handler = { result in
        modelHandler(ModelType.initialize(with: result))
    }
    
    data.0.task?.resume()
    
    return data.0.task
}

infix operator *| // Combine model/request with service

@discardableResult
public func *| <Session: SessionService, Model: NetworkProcessable> (
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

infix operator +| // Combine request with query params
public func +| <ModelType, Params: QueryParamsType>(model: ModelType.Type, params: Params) -> Request<ModelType>
    where ModelType: NetworkProcessable
{
    let encoder = JSONEncoder()
    let data = (try? encoder.encode(params)) ?? Data()
    
    let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String : Any]
    
    let url = model.url +? (dictionary ?? [:])
    
    return Request(modelType: model, url: url)
}

public func +| <ModelType, Params: BodyParamsType>(model: ModelType.Type, params: Params) -> Request<ModelType>
    where ModelType: NetworkProcessable
{
    let encoder = JSONEncoder()
    
    let data = (try? encoder.encode(params)) ?? Data()
    
    let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String : Any]
    
    let encoded = dictionary?.multipartRequestConverted() ?? Data()
    
    let url = model.url
    
    return Request(modelType: model, url: url, body: encoded)
}
