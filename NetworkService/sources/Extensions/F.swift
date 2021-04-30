//
//  Operators.swift
//  NetworkService
//
//  Created by Kikacheishvili Bogdan on 30.04.2021.
//  Copyright © 2021 Bendis. All rights reserved.
//

import Foundation

public typealias Func<T, R> = (T) -> (R)
public typealias VoidFunc<T> = (T) -> ()
public typealias TupleCallback<T, T1> = (T, T1) -> ()
public typealias TrippleCallback<T, T1, T2> = (T, T1, T2) -> ()
public typealias Callback<T> = (T) -> ()
public typealias VoidCallback = () -> ()

public func make<Result>(_ count: Int, _ execute: (Int) -> Result) -> [Result] {
    var array = [Result]()
    
    for index in 0..<count {
        array.append(execute(index))
    }
    
    return array
}

public func make(_ count: Int, _ execute: (Int) -> Void) {
    for index in 0..<count {
        execute(index)
    }
}

public func when<Result>(_ condition: Bool, execute: () -> Result?) -> Result? {
    return condition ? execute() : nil
}

public func call<Result>(execute: () -> Result) -> Result {
    return execute()
}

public enum F {
    
    public static func lift<Value>(_ value: Value) -> () -> Value {
        return { value }
    }
    
    public static func identity<Value>(_ value: Value) -> Value {
        return value
    }
}

public func and(lhs: Bool, rhs: Bool) -> Bool {
    return lhs && rhs
}

public func or(lhs: Bool, rhs: Bool) -> Bool {
    return lhs || rhs
}

public func cast<Value, Result>(_ value: Value) -> Result? {
    return value as? Result
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in
        { f(a, $0 ) }
    }
}

public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in
        { b in { f(a, b, $0) } }
    }
}

public func flip<A, B, Result>(_ f: @escaping (A, B) -> Result) -> (B, A) -> Result {
    return { f($1, $0) }
}

public func flip<A, B, C, Result>(_ f: @escaping (A, B, C) -> Result) -> (C, B, A) -> Result {
    return { f($2, $1, $0) }
}
