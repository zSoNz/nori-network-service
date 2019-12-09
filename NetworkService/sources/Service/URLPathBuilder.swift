//
//  PathBuilder.swift
//  NetworkService
//
//  Created by IDAP Developer on 12/9/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import Foundation

public struct URLPathBuilder {
    
    let host: String
    let version: String
    let components: [String]
    
    public init(host: String, version: String, components: [String]) {
        self.host = host
        self.version = version
        self.components = components
    }
    
    public func append(component: String) -> URLPathBuilder {
        return URLPathBuilder(host: self.host,
                              version: self.version,
                              components: self.components + [component])
    }
    
    public func append(components: [String]) -> URLPathBuilder {
        if !components.isEmpty {
            return components.reduce(self) { (result, component) in result.append(component: component) }
        } else {
            return self
        }
    }
    
    public func build() -> URL {
        let version = self.version.isEmpty ? [] : [self.version]
        let pathComponents = [self.host] + version + self.components
        let fullPath = pathComponents.joined(separator: "/")
        return URL(string: fullPath)!
    }
}
