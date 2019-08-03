import UIKit

infix operator =>: DefaultPrecedence // GET

protocol URLContainable {
    
    static var url: URL { get }
}

protocol DataInitiable {
    
    associatedtype DataType
    
    static func initialize(with data: DataType) -> Self
}

protocol NetworkProcessable: URLContainable, DataInitiable {
    
}

protocol Task {
   
    func resume()
    func cancel()
}

class UrlSessionTask: Task {
    
    private let task: URLSessionDataTask
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    func resume() {
        self.task.resume()
    }
    
    func cancel() {
        self.task.cancel()
    }
}

protocol SessionService {
    
    associatedtype DataType
    
    static func dataTask(url: URL, completion: @escaping (DataType) -> ()) -> Task
}

class UrlSessionService: SessionService {
    
    typealias DataType = Data?
    
    private static let session = URLSession.shared
    
    static func dataTask(url: URL, completion: @escaping (DataType) -> ()) -> Task {
        let dataTask = self.session.dataTask(with: url) { data, _, _ in
            completion(data!)
        }
        
        let task = UrlSessionTask(task: dataTask)
        
        return task
    }
}

typealias ModelHandler<Type> = (Type) -> ()

class TaskExecutableDataHandler<ModelType> {
    
    var handler: ModelHandler<ModelType>?
    var task: Task?
    
    init(handler: ModelHandler<ModelType>?, task: Task?) {
        self.handler = handler
        self.task = task
    }
}

typealias NetworkOperationComposingResult<DataType, ModelType> = (TaskExecutableDataHandler<DataType>, ModelType)

infix operator *
func * <Session, Model, DataType> (session: Session.Type, model: Model.Type) -> NetworkOperationComposingResult<DataType, Model.Type>
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


func => <DataType, ModelType>(data: NetworkOperationComposingResult<DataType, ModelType.Type>, modelHandler: @escaping ModelHandler<ModelType>)
    where ModelType: NetworkProcessable, ModelType.DataType == DataType
{
    print("test")
    data.0.handler = { result in
        modelHandler(ModelType.initialize(with: result))
    }
    data.0.task?.resume()
}

struct Error: NetworkProcessable, Codable {
    
    typealias DataType = Data?
    
    static var url = URL(string: "http://history.openweathermap.org/data/2.5/history/city?id=1&type=hour")!
    
    let cod: Int
    let message: String
}

extension NetworkProcessable where Self: Codable {
    
    static func initialize(with data: Data?) -> Self {
        return try! JSONDecoder().decode(Self.self, from: data!)
    }
}

(UrlSessionService.self * Error.self) => { result in
    print(result.cod)
    print(result.message)
}

