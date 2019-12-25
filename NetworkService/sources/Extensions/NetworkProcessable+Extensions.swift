//
//  NetworkProcessable+Extensions.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

public extension NetworkProcessable where ReturnedType: Codable {
    
    static func initialize(with data: Result<Data, Error>) -> Result<ReturnedType, Error> {
        do {
            let data = try data.get()
            let decoded = try JSONDecoder().decode(ReturnedType.self, from: data)
            
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
}
