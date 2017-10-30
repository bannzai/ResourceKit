//
//  ReusableResourceOutput.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public protocol ReusableResourceOutput: Output {
    
}

public struct ReusableResourceOutputImpl: ReusableResourceOutput {
    let className: String
    let reusableIdentifers: Set<String>
    
    public var declaration: String {
        let names = reusableIdentifers
            .map {
                return "       static let name: String = \"\($0)\""
            }
            .joined(separator: Const.newLine)
        
        return [
            "extension \(className) {",
            "   struct Reusable: ReusableProtocol {",
            "       typealias View = \(className)",
            "\(names)",
            "   }",
            "}",
        ].joined(separator: Const.newLine)
    }
}