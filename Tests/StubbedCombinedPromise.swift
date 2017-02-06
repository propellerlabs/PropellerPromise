//
//  StubbedCombinedPromise.swift
//  PropellerPromise
//
//  Created by RGfox on 2/6/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation
@testable import PropellerPromise

class StubbedCombinedPromise: CombinePromise {
    
    override init(promises: [Promisable] ) {
        super.init(promises: promises)
    }
    
    public var onDeinit:() -> Void = {
        assert(false, "set deinit checker")
    }
    
    deinit {
        onDeinit()
    }
}
