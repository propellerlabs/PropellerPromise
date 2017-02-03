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
    
    @discardableResult
    public func always(action: @escaping () -> Void) -> Promise<Wrapped> {
        alwaysRun = action
        return self
    }
}
