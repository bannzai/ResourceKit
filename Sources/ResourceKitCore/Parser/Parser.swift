//
//  parser.swift
//  o
//
//  Created by kingkong999yhirose on 2016/04/12.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

public protocol Parsable: XMLParserDelegate {
    func parse() throws
}


