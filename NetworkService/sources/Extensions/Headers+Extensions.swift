//
//  Headers+Extensions.swift
//  NetworkService
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

public extension Headers where Self: Encodable {
    
    var dictionary: [String: String] {
        let encoder = JSONEncoder()
        let data = (try? encoder.encode(self)) ?? Data()
        
        let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String : String]
        return dictionary ?? [:]
    }
}
