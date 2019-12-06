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
    
    let _id: String
    let text: String
    let type: String
}

struct CatsModel: NetworkModel {
    
    var all: [Cat]
}

struct Cats: NetworkProcessable {
    
    typealias ReturnedType = CatsModel
    typealias Service = UrlSessionService
    
    static var url = URL(string: "https://cat-fact.herokuapp.com/facts")!
}

struct Post: NetworkModel {
    
    let id: Int
    let title: String?
    let body: String?
    let userId: String?
}

struct PostModel: NetworkProcessable {
    
    typealias Service = UrlSessionService
    typealias ReturnedType = Post
    
    static var url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
}

struct MockableCats: NetworkProcessable {
    
    typealias ReturnedType = CatsModel
    typealias Service = LocalSessionService
    
    static var url = URL(string: "https://cat-fact.herokuapp.com/facts")!
    
    static func initialize(with data: Result<Data, Error>) -> Result<MockableCats, Error> {
        return .success(MockableCats(all: []))
    }
    
    let all: [Cat]
}

class MainViewController<CatsProvider: NetworkProcessable>: UIViewController
    where CatsProvider.ReturnedType == CatsModel
{

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
        
        (PostModel.self +| PostBody()) |=> { result in
            print(result)
        }
    }
    
    //MARK: -
    //MARK: Private
    
    private func fill() {
        self.text?.text = self.facts?.all.randomElement()?.text
    }
    
    private func prepareData() {
        CatsProvider.self <=| { result in
            _ = result.map { cats in
                DispatchQueue.main.async {
                    self.facts = cats
                }
            }
        }
    }
}
