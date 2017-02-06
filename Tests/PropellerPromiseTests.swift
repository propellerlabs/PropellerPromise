//
//  PropellerPromiseTests.swift
//  PropellerPromiseTests
//
//  Created by RGfox on 1/31/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import XCTest
import PropellerPromise

class PropellerPromiseTests: XCTestCase {
    
    let successString = "FINISHED!"
    
    func successPromise() -> Promise<String> {
        let promise = Promise<String>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill(self.successString)
        }
        return promise
    }
    
    func failurePromise() -> Promise<String> {
        let promise = Promise<String>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.reject(RequestError.unknown)
        }
        return promise
    }
    
    func testThenChainingPromise() {
        let expectation1 = self.expectation(description: "fire then string promise")
        let expectation2 = self.expectation(description: "fire then bool promise")
        let expectation3 = self.expectation(description: "fire then int promise")
        successPromise()
        .then { val -> Bool in
            expectation1.fulfill()
            return val == self.successString
        }
        .then { isSuccess -> Int in
            expectation2.fulfill()
            return isSuccess ? 1 : 0
        }
        .then { successInt -> Void in
            expectation3.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testThenFailingChainingPromise() {
        let expectation = self.expectation(description: "should fire failure")
        failurePromise()
            .then { val -> Bool in
                XCTFail()
                return val == self.successString
            }
            .then { isSuccess -> Int in
                XCTFail()
                return isSuccess ? 1 : 0
            }
            .failure(RequestError.self) { error in
                expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSuccessStringPromise() {
        let expectation = self.expectation(description: "should return success \(self.successString)")
        successPromise()
        .complete { value in
            XCTAssert(value == self.successString)
            expectation.fulfill()
        }
        .failure { error in
            XCTFail("should succeed, error: \(error)")
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFailureStringPromise() {
        let expectation = self.expectation(description: "should return error")
        failurePromise()
        .complete { value in
            XCTFail("should fail!, value: \(value)")
        }
        .failure(RequestError.self) { error in
            switch error {
            case .unknown : break
            default: XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAlwaysPromiseSuccess() {
        let expectation1 = self.expectation(description: "fire on completion")
        let expectation2 = self.expectation(description: "fire always")
        successPromise()
        .complete { val in
            expectation1.fulfill()
        }
        .failure { error in
            XCTFail()
        }
        .always {
            expectation2.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAlwaysPromiseFailure() {
        let expectation1 = self.expectation(description: "fire on failure")
        let expectation2 = self.expectation(description: "fire always")
        failurePromise()
            .complete { val in
                XCTFail()
            }
            .failure { error in
                expectation1.fulfill()
            }
            .always {
                expectation2.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
