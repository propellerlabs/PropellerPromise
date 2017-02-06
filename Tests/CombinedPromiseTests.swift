//
//  CombinedPromiseTests.swift
//  PropellerPromise
//
//  Created by RGfox on 2/6/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import XCTest
@testable import PropellerPromise

class CombinePromiseTests: XCTestCase {
    
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
    
    func testCombinedPromiseSuccess() {
        let expectation1 = self.expectation(description: "promise 1 finished")
        let expectation2 = self.expectation(description: "promise 2 finished")
        let expectation3 = self.expectation(description: "promise 3 finished")
        let expectation4 = self.expectation(description: "combined proimse finished")
        var p1Done = false
        var p2Done = false
        var p3Done = false
        let p1 = successPromise()
            .complete { value in
                expectation1.fulfill()
                p1Done = true
            }
            .failure { error in
                XCTFail()
        }
        let p2 = successPromise()
            .complete { value in
                expectation2.fulfill()
                p2Done = true
            }
            .failure { error in
                XCTFail()
        }
        let p3 = successPromise()
            .complete { value in
                expectation3.fulfill()
                p3Done = true
            }
            .failure { error in
                XCTFail()
        }
        let _ = CombinePromise(promises: [p1,p2,p3])
            .complete {_ in
                XCTAssert(p1Done)
                XCTAssert(p2Done)
                XCTAssert(p3Done)
                expectation4.fulfill()
            }
            .failure { _ in
                XCTFail()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCombinedPromiseFailed() {
        let expectation1 = self.expectation(description: "promise 1 finished")
        let expectation2 = self.expectation(description: "promise 2 finished")
        let expectation3 = self.expectation(description: "promise 3 finished")
        let expectation4 = self.expectation(description: "combined proimse finished")
        var p1Done = false
        var p2Done = false
        var p3Done = false
        let p1 = successPromise()
            .complete { value in
                expectation1.fulfill()
                p1Done = true
            }
            .failure { error in
                XCTFail()
        }
        let p2 = successPromise()
            .complete { value in
                expectation2.fulfill()
                p2Done = true
            }
            .failure { error in
                XCTFail()
        }
        let p3 = failurePromise()
            .complete { value in
                XCTFail()
                p3Done = true
            }
            .failure { error in
                expectation3.fulfill()
        }
        CombinePromise(promises: [p1,p2,p3])
            .complete {_ in
                XCTFail()
            }
            .failure(MultiError.self) { errors in
                XCTAssert(errors.errors.count == 1)
                XCTAssert(p1Done)
                XCTAssert(p2Done)
                XCTAssert(!p3Done)
                expectation4.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testRetainCycleCombinedPromiseOnSuccess() {
        let expectation1 = self.expectation(description: "promise 1 should be  finished")
        let expectation2 = self.expectation(description: "combined promise should be fired")
        let expectation3 = self.expectation(description: "combined promise deinit should be called")
        var p1Done = false
        let p1 = successPromise()
            .complete { value in
                expectation1.fulfill()
                p1Done = true
            }
            .failure { error in
                XCTFail()
        }
        (StubbedCombinedPromise(promises: [p1])
            .complete {_ in
                XCTAssert(p1Done)
                expectation2.fulfill()
            }
            .failure(MultiError.self) { errors in
                XCTFail()
            }
            as? StubbedCombinedPromise)?
        .onDeinit = {
            expectation3.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testRetainCycleCombinedPromiseOnFailure() {
        let expectation1 = self.expectation(description: "promise 1 should be  finished")
        let expectation2 = self.expectation(description: "combined promise should be fired")
        let expectation3 = self.expectation(description: "combined promise deinit should be called")
        var p1Done = false
        let p1 = failurePromise()
            .complete { value in
                XCTFail()
            }
            .failure { error in
                expectation1.fulfill()
                p1Done = true
        }
        (StubbedCombinedPromise(promises: [p1])
            .complete {_ in
                XCTFail()
            }
            .failure(MultiError.self) { errors in
                XCTAssert(p1Done)
                XCTAssert(errors.errors.count == 1)
                expectation2.fulfill()
            }
            as? StubbedCombinedPromise)?
            .onDeinit = {
                expectation3.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testDuplicatePromises() {
        let expectation1 = self.expectation(description: "promise 1 should be  finished")
        let expectation2 = self.expectation(description: "combined promise should be fired")
        //let expectation3 = self.expectation(description: "combined promise deinit should be called")
        var p1Done = false
        let p1 = successPromise()
            .complete { value in
                expectation1.fulfill()
                p1Done = true
            }
            .failure { error in
                XCTFail()
        }
        CombinePromise(promises: [p1, p1])
            .complete {_ in
                XCTAssert(p1Done)
                expectation2.fulfill()
            }
            .failure(MultiError.self) { errors in
                XCTFail()
            }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
