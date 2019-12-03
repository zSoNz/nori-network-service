//
//  URL+Extensions.swift
//  Network Service
//
//  Created by IDAP Developer on 12/3/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

infix operator +?: AdditionPrecedence

public extension URL {
    
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
