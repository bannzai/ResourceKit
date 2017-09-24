//
//  ReusableResourceOutput.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol ReusableResourceOutput: Output {
    
}

struct ReusableResourceOutputImpl: ReusableResourceOutput {
    let accessControl: String
    let className: String
    let reusableIdentifers: Set<String>
    
    var declaration: String {
        let names = reusableIdentifers
            .map {
                return "       \(accessControl) let name: String = \"\($0)\""
            }
            .joined(separator: newLine)
        
        return [
            "\(accessControl) extension \(className) {",
            "   \(accessControl) struct ReusableImpl: Reusable {",
            "       \(accessControl) typealias View = \(className)",
            "\(names)",
            "   }",
            "}",
        ].joined(separator: newLine)
    }
}
