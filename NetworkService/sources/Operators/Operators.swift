//
//  Operators.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

infix operator <==: DefaultPrecedence // GET
public func <== <DataType, ModelType>(
    data: NetworkOperationComposingResult<DataType, ModelType.Type>,
    modelHandler: @escaping ModelHandler<ModelType>
)
    where ModelType: NetworkProcessable, ModelType.DataType == DataType
{
    data.0.handler = { result in
        modelHandler(ModelType.initialize(with: result))
    }
    
    data.0.task?.resume()
}

infix operator ** // Combine model/request with service
public func ** <Session, Model, DataType> (session: Session.Type, model: Model.Type) -> NetworkOperationComposingResult<DataType, Model.Type>
    where Session: SessionService, Session.DataType == DataType,
          Model: NetworkProcessable, Model.DataType == DataType
{
    let handlerContainer = TaskExecutableDataHandler<DataType>(handler: nil, task: nil)
    
    let task = session.dataTask(url: model.url) {
        handlerContainer.handler?($0)
    }
    
    handlerContainer.task = task
    
    return (handlerContainer, model)
}

@discardableResult
public func ** <Session, Model, DataType> (
    session: Session.Type,
    request: Request<Model>
) -> NetworkOperationComposingResult<DataType, Model.Type>
    where Session: SessionService, Session.DataType == DataType,
    Model: NetworkProcessable, Model.DataType == DataType
{
    let handlerContainer = TaskExecutableDataHandler<DataType>(handler: nil, task: nil)
    
    let task = session.dataTask(url: request.url) {
        handlerContainer.handler?($0)
    }
    
    handlerContainer.task = task
    
    return (handlerContainer, Model.self)
}

infix operator ++ // Combine request with params
public func ++ <ModelType, DataType>(model: ModelType.Type, params: RequestParametrsQuery) -> Request<ModelType>
    where ModelType: NetworkProcessable, ModelType.DataType == DataType
{
    let url = model.url +? (params.params ?? [:])
    
    return Request(modelType: model, url: url)
}