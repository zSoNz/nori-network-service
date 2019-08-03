import Foundation

infix operator +?: AdditionPrecedence

extension URL {
    
    static func + (left: URL, right: String) -> URL {
        return left.appendingPathComponent(right)
    }
    
    static func +? (left: URL, right: [String: Any]) -> URL {
        guard var urlComponents = URLComponents(string: left.absoluteString) else {
            return left.absoluteURL
        }
        
        urlComponents.queryItems = right.map {
            URLQueryItem(name: $0.key, value: "\($0.value)")
        }
        
        guard let resultURL = urlComponents.url else {
            return left.absoluteURL
        }
        
        return resultURL
    }
}

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

struct RequestParametrsQuery {
    
    let params: [String : String]?
}

struct Request<ModelType>
    where ModelType: NetworkProcessable
{
    
    let modelType: ModelType.Type
    let url: URL
}

infix operator +
func + <ModelType, DataType>(model: ModelType.Type, params: RequestParametrsQuery) -> Request<ModelType>
    where ModelType: NetworkProcessable, ModelType.DataType == DataType
{
    let url = model.url +? (params.params ?? [:])
    
    return Request(modelType: model, url: url)
}

infix operator <=: DefaultPrecedence // GET
func <= <DataType, ModelType>(data: NetworkOperationComposingResult<DataType, ModelType.Type>, modelHandler: @escaping ModelHandler<ModelType>)
    where ModelType: NetworkProcessable, ModelType.DataType == DataType
{
    data.0.handler = { result in
        modelHandler(ModelType.initialize(with: result))
    }
    data.0.task?.resume()
}

@discardableResult
func * <Session, Model, DataType> (session: Session.Type, request: Request<Model>) -> NetworkOperationComposingResult<DataType, Model.Type>
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

let params = RequestParametrsQuery(params: [
    "id" : "1",
    "type" : "hour"
])

(UrlSessionService.self * (Error.self + params)) <= { result in
    print(result.cod)
}
//let test1 = (UrlSessionService.self * (Error.self + params))

