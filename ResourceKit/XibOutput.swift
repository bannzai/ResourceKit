//
//  XibOutput.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol XibOutput: Output {
    
}

struct XibOutputImpl: XibOutput {
    let accessControl: String
    let nibName: String
    let className: String
    
    var declaration: String {
        return [
            "\(accessControl) extension \(className) {",
            "\(tab1)\(accessControl) struct XibImpl: Xib {",
            "\(tab2)\(accessControl) typealias View = \(className)",
            "\(tab2)\(accessControl) let name: String = \"\(className)\"",
            "       ",
            "\(tab2)\(accessControl) func nib() -> UINib {",
            "\(tab3)return UINib(nibName: \"\(nibName)\", bundle: Bundle(for: \(className).classForCoder()))",
            "\(tab2)}",
            "",
            "\(tab2)\(accessControl) func view() -> \(className) {",
            "\(tab3)return nib().instantiate(withOwner: nil, options: nil)[0] as! \(className)",
            "\(tab2)}",
            "",
            "\(tab1)}",
            "}",
            ].joined(separator: newLine)
    }
}
