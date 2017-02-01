 //
//  Result.swift
//  PropellerPromise
//
//  Created by RGfox on 1/31/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

 enum Result<Wrapped> {
    case error(Error),
    some(Wrapped)
    
    init(_ val: Error) {
        self = Result.error(val)
    }
    
    init(_ val: Wrapped) {
        self = Result.some(val)
    }
    
    func propel(target: Promise<Wrapped>) {
        switch self {
        case .error(let err):
            target.failedRun?(err)
        case .some(let val):
            target.completeRun?(val)
            target.thenRun?(val)
        }
        target.alwaysRun?()
        target.alwaysRun = nil
    }
}
