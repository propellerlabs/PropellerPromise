//
//  RequestError.swift
//  PropellerPromise
//
//  Created by RGfox on 1/31/17.
//  Copyright © 2017 Propeller. All rights reserved.
//

import PropellerPromise

enum RequestError: Error {
    case data(Data)
    case message(String)
    case unknown
    
    init(data: Data) {
        self = RequestError.data(data)
    }
    init(unknown: String) {
        self = RequestError.message(unknown)
    }
}
