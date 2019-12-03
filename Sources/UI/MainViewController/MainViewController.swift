//
//  MainViewController.swift
//  Nori Network Service
//
//  Created by IDAP Developer on 8/5/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import UIKit

import NetworkService

struct ErrorParams: Encodable {
    
    let id = 0
    let type = "hour"
}

struct Error: NetworkProcessable, Codable {
    
    typealias DataType = Data
    
    static var url = URL(string: "https://history.openweathermap.org/data/2.5/history/city")!
    
    let cod: Int
    let message: String
}

class MainViewController: UIViewController {

    //MARK: -
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareData()
    }
    
    //MARK: -
    //MARK: Private
    
    private func prepareData() {
        let params = ErrorParams()
        
        (UrlSessionService.self ** (Error.self ++ params)) <== { result in
            print(result)
        }
    }
}
