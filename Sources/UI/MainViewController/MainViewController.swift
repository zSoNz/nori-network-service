//
//  MainViewController.swift
//  Nori Network Service
//
//  Created by IDAP Developer on 8/5/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import UIKit

import NetworkService

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

struct Cats: NetworkProcessable, Codable {
    
    typealias DataType = Data
    
    static var url = URL(string: "https://cat-fact.herokuapp.com/facts")!
    
    let all: [Cat]
    
}

class MainViewController: UIViewController {

    @IBOutlet var text: UILabel?
    
    //MARK: -
    //MARK: IBActions
    
    @IBAction func random(_ sender: Any) {
        self.fill()
    }
    
    //MARK: -
    //MARK: Variables
    
    private var facts: Cats? {
        didSet {
            self.fill()
        }
    }
    
    //MARK: -
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareData()
    }
    
    //MARK: -
    //MARK: Private
    
    private func fill() {
        self.text?.text = self.facts?.all.randomElement()?.text
    }
    
    private func prepareData() {
        let params = EmptyParams()
        
        (UrlSessionService.self *| (Cats.self +| params)) <=| { result in
            _ = result.map { cats in
                DispatchQueue.main.async {
                    self.facts = cats
                }
            }
        }
    }
}
