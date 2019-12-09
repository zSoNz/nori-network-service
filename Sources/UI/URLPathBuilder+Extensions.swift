//
//  URLPathBuilder+Extensions.swift
//  NetworkService
//
//  Created by IDAP Developer on 12/9/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

import NetworkService

@propertyWrapper
struct CatAPI {
    
    private(set) var wrappedValue: URL
    
    init(value: String) {
        self.wrappedValue = URLPathBuilder(
            host: "https://cat-fact.herokuapp.com",
            version: "",
            components: [value]
        ).build()
    }
}
