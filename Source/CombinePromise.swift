//
//  CombinePromise.swift
//  PropellerPromise
//
//  Created by RGfox on 2/2/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

public protocol Promisable {
    var combined: CombinePromise? { get set }
}

public struct MultiError: Error {
    public init(errors: [Error]) {
        self.errors = errors
    }
    public let errors: [Error]
}

public final class CombinePromise: Promise<[Any]> {
    
    public typealias ErrorType = MultiError
        
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
    
    public init(promises: Promisable... ) {
        expectedCount = promises.count
        super.init()
        for (var promise) in promises {
            promise.combined = self
        }
    }
}
