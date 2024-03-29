//
//  MainViewController.swift
//  Nori Network Service
//
//  Created by IDAP Developer on 8/5/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import UIKit

import NetworkService

struct PostBody: BodyParamsType {
    
    let title = "foo"
    let body = "bar"
    let userId = "1"
}

struct EmptyParams: Encodable {
    
    let lat = 37.75
    let lon = -122.37
    let appid = "b6907d289e10d714a6e88b30761fae22"
}

struct Cat: Codable {
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
    }
    
    let type: String?
    let text: String?
}

struct CatsModel: NetworkModel {
    
    var all: [Cat]
}

struct Post: NetworkModel {
    
    let id: Int
    let title: String?
    let body: String?
    let userId: String?
}

class PostModel: NetworkProcessable {
    
    typealias Service = UrlSessionService
    typealias ReturnedType = Post
    
    static var url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
}

class Cats: NetworkProcessable {
    
    typealias ReturnedType = [Cat]
    
    @CatAPI(value: "facts") static var url
    
    static func initialize(with data: Result<DataType, Error>) -> Result<CatsModel, Error> {
        .success(CatsModel(all: [Cat(type: "Неко дуже кьют", text: "Мяу")]))
    }
}

class MainViewController<Service: DataSessionService>: UIViewController {

    @IBOutlet var text: UILabel?
    
    //MARK: -
    //MARK: IBActions
    
    @IBAction func random(_ sender: Any) {
        self.fill()
    }
    
    //MARK: -
    //MARK: Variables
    
    private var facts: CatsModel? {
        didSet {
            self.fill()
        }
    }
    
    //MARK: -
    //MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "MainViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareData()
        Service.request(model: PostModel.self, params: PostBody()) |*| post { result in
            
        }
    }
    
    //MARK: -
    //MARK: Private
    
    private func fill() {
        self.text?.text = self.facts?.all.randomElement()?.text
    }
    
    private func prepareData() {
        Service.request(model: Cats.self) |*| get { result in
            _ = result.map { cats in
                DispatchQueue.main.async {
                    self.facts = CatsModel(all: cats)
                }
            }
        }
    }
}
