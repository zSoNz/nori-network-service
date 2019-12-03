//
//  Operators.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

infix operator <=|: DefaultPrecedence // GET
public func <=| <ModelType: NetworkProcessable, ServiceType>(
    request: Request<ModelType>,
    modelHandler: @escaping ModelHandler<Result<ModelType, Error>>
)
    where ServiceType.DataType == ModelType.DataType, ModelType.Service == ServiceType
{
    let data = (ServiceType.self *| ModelType.self)
    
    data.0.handler = { result in
        modelHandler(ModelType.initialize(with: result))
    }
    
    data.0.task?.resume()
}

public func <=| <ModelType: NetworkProcessable, ServiceType>(
    model: ModelType.Type,
    modelHandler: @escaping ModelHandler<Result<ModelType, Error>>
)
    where ServiceType == ModelType.Service, ServiceType.DataType == ModelType.DataType
{
    Request<ModelType>(modelType: model, url: model.url) <=| modelHandler
}

infix operator *| // Combine model/request with service
public func *| <Session: SessionService, Model: NetworkProcessable> (
    session: Session.Type,
    model: Model.Type
)
    -> NetworkOperationComposingResult<Model.DataType, Model.Type> where Session.DataType == Model.DataType
{
    let handlerContainer = TaskExecutableDataHandler<Model.DataType>(handler: nil, task: nil)
    
    let task = session.dataTask(url: model.url) {
        handlerContainer.handler?($0)
    }
    
    handlerContainer.task = task
    
    return (handlerContainer, model)
}

@discardableResult
public func *| <Session: SessionService, Model: NetworkProcessable> (
    session: Session.Type,
    request: Request<Model>
)
    -> NetworkOperationComposingResult<Model.DataType, Model.Type> where Session.DataType == Model.DataType
{
    let handlerContainer = TaskExecutableDataHandler<Model.DataType>(handler: nil, task: nil)
    
    let task = session.dataTask(url: request.url) {
        handlerContainer.handler?($0)
    }
    
    handlerContainer.task = task
    
    return (handlerContainer, Model.self)
}

infix operator +| // Combine request with params
public func +| <ModelType, Params: Encodable>(model: ModelType.Type, params: Params) -> Request<ModelType>
    where ModelType: NetworkProcessable
{
    let encoder = JSONEncoder()
    let data = (try? encoder.encode(params)) ?? Data()
    
    let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String : Any]
    
    let url = model.url +? (dictionary ?? [:])
    
    return Request(modelType: model, url: url)
}
