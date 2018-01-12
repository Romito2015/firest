//
//  Extensions.swift
//  firest
//
//  Created by Roma Chopovenko on 1/9/18.
//  Copyright © 2018 Roma Chopovenko. All rights reserved.
//

import Foundation

func createError(withTitle title: String, domain: String, code: Int? = nil) -> Error {
    var defaultCode: Int = -111
    if let theCode = code {
        defaultCode = theCode
    }
    let error: Error = NSError(domain: domain,
                               code: defaultCode,
                               userInfo: [NSLocalizedDescriptionKey: title]) as Error
    return error
}
