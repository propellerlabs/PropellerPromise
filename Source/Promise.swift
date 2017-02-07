//
//  PromiseKit.swift
//  PropellerPromise
//
//  Created by Richard Fox on 1/31/17.
//  Copyright © 2016 Promise. All rights reserved.
//

import Foundation

protocol ThenPromiseable {
    var failedRun: ((Error) -> Void)? { get set }
    var thenFail: ThenPromiseable? { get }
}

/// Class that represents a promise/future. Once created a `Promise` object
/// can be returned immediately and either `complete` `then` or `failure` will
/// be called later when an async tasks passes in a fullfillment value or
/// rejection error.
public class Promise<Wrapped>: Promisable, ThenPromiseable {
    
    /// Create new promise
    public init() {}
    
    /// `CombinePromise` that will be fired after this `Promise` is 
    /// fullfilled/rejected (iff all other `Promise`s being waited on by the
    /// `CombinedPromise` are also fullfilled/rejected)
    public var combined: CombinePromise?
    
    typealias CompleteType = ((Wrapped) -> Void)

    /**
    When async task is completed successfully with a `Wrapped` value. Pass it 
     into the promise via `fullfill(:)`
     
    - Parameters:
        - value: provide a Promise associated type or `Wrapped` value.
    */
    public func fulfill(_ value: Wrapped) {
        let result = Result<Wrapped>(value)
        result.propel(target: self)
        combined?.setResult(value: value)
        combined = nil
    }
    
    /**
     When async task is finished with a failure an `Error` value should be 
     passed into this `reject(:)` function to trigger the promise's `failure` case.
     
     - Parameters:
        - value: provide a type conforming to `Error`
    */
    public func reject(_ value: Error) {
        let result = Result<Wrapped>(value)
        result.propel(target: self)
        combined?.setError(error: value)
        combined = nil
    }
    
    var alwaysRun: (() -> Void)?
    var completeRun: CompleteType?
    var failedRun: ((Error) -> Void)?
    var thenRun: CompleteType?
    var thenFail: ThenPromiseable?

    /**
     Allows async response for `then` case, which will return a new promise 
     matching the return type specified in your `action` parameter. 
     Called iff promise is fullfilled.
     
     - Parameters:
         - type: provide a type conforming to `Error`
         - action: throwable function that takes in `Wrapped` value and returns
    a generic `U` value.
     
     - Returns: created a new `Promise<U>` where `U` is the return type of the 
     `action` parameter
    */
    @discardableResult
    public func then<U>(action: @escaping (Wrapped) throws -> U) -> Promise<U> {
        let promise = Promise<U>()
        thenRun = { val in
            if let res = try? action(val) {
                promise.fulfill(res)
            }
        }
        thenFail = promise
        return promise
    }

    /**
     Allows async response for completion case. Called iff promise is fullfilled.
     
     - Parameters:
        - action: failure action function that takes in generic `Wrapped` 
     associated type.
     
     - Returns: `self` which is of type `Promise<Wrapped>`
     */
    @discardableResult
    public func complete(action: @escaping (Wrapped) -> Void) -> Promise<Wrapped> {
        completeRun = action
        return self
    }

    /**
     Allows async response for failure case with way to cast to an Error type.
     Called iff promise is rejected.
     
     - Parameters:
        - action: failure action function that takes in a type comforming to `Error`.
     
     - Returns: `self` which is of type `Promise<Wrapped>`
     */
    @discardableResult
    public func failure(action: @escaping (Error) -> Void) -> Promise<Wrapped> {
        failedRun = action
        return self
    }
    
    /**
     Allows async response for failure case with way to cast to an Error type. 
     If the `type` provided is incorrect this is handled as programmer error, 
     an assert is thrown and the failure action is not called. Called iff promise
     is rejected.
     
     - Parameters:
        - type: provide a type conforming to `Error`
        - action: failure action function that takes in `type` specified via previous 
     parameter.
     
     - Returns: `self` which is of type `Promise<Wrapped>`
    */
    @discardableResult
    public func failure<T: Error>(_ type: T.Type, action: @escaping (T) -> Void) -> Promise<Wrapped> {
        failedRun = { (error: Error) in
            guard let res = error as? T else {
                assert(false, "invalid cast from error type :\(type(of: error)) to error type :\(type)")
                return
            }
            action(res)
        }
        return self
    }

    /**
     Allows async action response for always case. Will be called whether the promises
     is rejected or fullfilled.
     
     - Parameters:
         - action: action function.
     
     - Returns: `self` which is of type `Promise<Wrapped>`
     */
    @discardableResult
    public func always(action: @escaping () -> Void) -> Promise<Wrapped> {
        alwaysRun = action
        return self
    }
}
