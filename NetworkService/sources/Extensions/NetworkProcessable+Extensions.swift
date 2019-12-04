//
//  NetworkProcessable+Extensions.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

public extension NetworkModel where Self: Codable {
    
    static func initialize(with data: Result<Data, Error>) -> Result<Self, Error> {
        do {
            let data = try data.get()
            let decoded = try JSONDecoder().decode(Self.self, from: data)
            
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
}
