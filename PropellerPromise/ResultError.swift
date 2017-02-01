//
//  ResultError.swift
//  PropellerPromise
//
//  Created by RGfox on 1/31/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import Foundation

public protocol ResultError: Error {
    init(data: Data)
    init(unknown: String)
}

extension Error {
    
}
