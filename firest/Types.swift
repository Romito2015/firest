//
//  Types.swift
//  firest
//
//  Created by Roma Chopovenko on 1/9/18.
//  Copyright © 2018 Roma Chopovenko. All rights reserved.
//

import Foundation

typealias successCompletion<T: Any> = (T)->()
typealias successTwitterCompletion = (_ token: String, _ secret: String) -> ()
typealias failCompletion = (Error)->()
