//
//  parser.swift
// ResourceKit
//
//  Created by kingkong999yhirose on 2016/04/12.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

protocol Parsable: XMLParserDelegate {
    init(url: URL) throws
}


