//
//  Dictionary+Extension.swift
//  NetworkService
//
//  Created by IDAP Developer on 12/6/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

/*

 Data encoding based on RFC 7578: https://tools.ietf.org/html/rfc7578#page-10
 
*/

import Foundation

import UIKit

extension Dictionary {
    
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
    
    func multipartRequestConverted() -> Data {
        let boundary = "--" + Constants.boundary.rawValue
        
        var body = Data()
        
        body.append(boundary)
            
        self.forEach { key, value in
            
            let append = { (value: Any) in
                let key = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
                
                if let file = value as? File {
                    body.append("\r\n" + "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(file.name + file.fileExtension)\"\r\n")
                    
                    body.append("Content-Type: image/png\r\n\r\n")
                    body.append(file.fileData)
                    body.append("\r\n")
                } else {
                    body.append("\r\n" + "Content-Disposition: form-data; name=\"\(key)\"\r\n")
                    
                    if let data = value as? Data {
                        body.append("Content-Type: application/octet-stream\r\n\r\n")
                        body.append(data)
                        body.append("\r\n")
                    } else {
                        body.append("\r\n")
                        body.append("\(value)\r\n")
                    }
                }
                
                body.append(boundary)
            }
            
            if isOptional(value) {
                let optional = value as Optional<Any>
                
                switch optional {
                case .none:
                    break
                case let .some(value):
                    append(value)
                }
            } else {
                append(value)
            }
        }
        
        if String(data: body, encoding: .utf8) == boundary {
            body.append("\r\n" + boundary + "--")
        } else {
            body.append("--")
        }
        
        return body
    }
    
    private func isOptional(_ instance: Any) -> Bool {
        let mirror = Mirror(reflecting: instance)
        let style = mirror.displayStyle
        return style == .optional
    }
}

extension Data {
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension CharacterSet {
    
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
