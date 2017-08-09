//
//  Translator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/08/09.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol Translator {
    associatedtype Input
    associatedtype Output
    
    func translate(for input: Input) throws -> Output
}
