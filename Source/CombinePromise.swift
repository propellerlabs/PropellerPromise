//
//  CombinePromise.swift
//  PropellerPromise
//
//  Created by RGfox on 2/2/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

///Promisable: protocol used to expose `combined` property of a `Promise` while avoiding having to specify an associated type.
public protocol Promisable {
    /// `CombinePromise` that will be fired after this `Promise` is fullfilled/rejected (iff all other `Promise`s being waited on by the `CombinedPromise` are also fullfilled/rejected)
    var combined: CombinePromise? { get set }
}

///Error type that holds an array of `Error`s.  Used in conjunction with a `CombinedPromise` to return all rejected errors on `failure`
public struct MultiError: Error {
    /**
    Initializer for `MultiError` 
    - Parameters:
        - errors: Array of `Error` values
    */
    public init(errors: [Error]) {
        self.errors = errors
    }
    /// Array of `Error` values associated with this `MultiError`
    public let errors: [Error]
}

public final class CombinePromise: Promise<[Any]> {
    
    var result = [Any]()
    var errors = [Error]()
    let expectedCount: Int
    var fullfilledCount = 0
    
    func incrementPromise() {
        fullfilledCount += 1
        if fullfilledCount == expectedCount {
            fireCombinedPromise()
        }
    }
    func fireCombinedPromise() {
        if errors.isEmpty {
            fulfill(result)
        } else {
            reject(MultiError(errors: errors))
        }
    }
    
    func setError(error: Error) {
        errors.append(error)
        incrementPromise()
    }
    
    func setResult(value: Any) {
        result.append(value)
        incrementPromise()
    }
    
    /**
    Initializer for `CombinedPromise` requiring list of other `Promisable`s to wait on before being fired. If one or more of these `Promisable` values are rejected this `CombinedPromise` is also rejected. The protocol `Promisable` instead of the `Promise` class is used here to allow `Promise` objects with mixed associated values to be specified.
    - Parameters:
        - promises: Array of `Promisable` values (usually `Promise` objects) that must be fullfilled/rejected before this `CombinedPromise` will become fullfilled/rejected.
     
    */
    public init(promises: Promisable... ) {
        expectedCount = promises.count
        super.init()
        for (var promise) in promises {
            promise.combined = self
        }
    }
}
