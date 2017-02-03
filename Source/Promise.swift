//
//  PromiseKit.swift
//  PropellerPromise
//
//  Created by Richard Fox on 1/31/17.
//  Copyright © 2016 Promise. All rights reserved.
//

import Foundation

public class Promise<Wrapped>: Promisable {
    
    var combined: CombinePromise?
    public typealias ErrorType = Error

    typealias CompleteType = ((Wrapped) -> Void)

    func fulfill(_ value: Wrapped) {
        let result = Result<Wrapped>(value)
        result.propel(target: self)
        combined?.setResult(value: value)
        combined = nil
    }
    
    func reject(_ value: ErrorType) {
        let result = Result<Wrapped>(value)
        result.propel(target: self)
        combined?.setError(error: value)
        combined = nil
    }
    
    var alwaysRun: (() -> Void)?
    var completeRun: CompleteType?
    var failedRun: ((ErrorType) -> Void)?
    var thenRun: CompleteType?

    @discardableResult
    public func then<U>(action: @escaping (Wrapped) throws -> U) -> Promise<U> {
        let promise = Promise<U>()
        thenRun = { val in
            if let res = try? action(val) {
                promise.fulfill(res)
            }
        }
        return promise
    }

    @discardableResult
    public func complete(action: @escaping (Wrapped) -> Void) -> Promise<Wrapped> {
        completeRun = action
        return self
    }

    @discardableResult
    public func failure(action: @escaping (ErrorType) -> Void) -> Promise<Wrapped> {
        failedRun = action
        return self
    }
    
    /**
     Allows async response for failure case with way to cast to an Error type. If the `type` provided is incorrect this is handled as programmer error, an assert is thrown and the failure action is not called.
     - Parameters:
        - type: provide a type conforming to `Error`
        - action: failure action function that takes in `type` specified via previous parameter.
     - Returns: a `Promise<Wrapped>`
    */
    @discardableResult
    public func failure<T: Error>(_ type: T.Type, action: @escaping (T) -> Void) -> Promise<Wrapped> {
        failedRun = { (error: ErrorType) in
            guard let res = error as? T else {
                assert(false, "invalid cast to of error:\(type(of: error)) to errorType:\(type)")
                return
            }
            action(res)
        }
        return self
    }

    
    @discardableResult
    public func always(action: @escaping () -> Void) -> Promise<Wrapped> {
        alwaysRun = action
        return self
    }
}
