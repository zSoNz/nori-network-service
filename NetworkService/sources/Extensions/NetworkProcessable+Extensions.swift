//
//  NetworkProcessable+Extensions.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

public extension NetworkProcessable where Self: Codable {
    
    static func initialize(with data: Data?) -> Self {
        return try! JSONDecoder().decode(Self.self, from: data!)
    }
}
