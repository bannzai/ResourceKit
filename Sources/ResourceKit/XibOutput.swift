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
    let nibName: String
    let className: String
    
    var declaration: String {
        return [
            "extension \(className) {",
            "\(tab1)struct Xib: XibProtocol {",
            "\(tab2)typealias View = \(className)",
            "\(tab2)static let name: String = \"\(className)\"",
            "       ",
            "\(tab2)static func nib() -> UINib {",
            "\(tab3)return UINib(nibName: \"\(nibName)\", bundle: Bundle(for: \(className).classForCoder()))",
            "\(tab2)}",
            "",
            "\(tab2)static func view() -> \(className) {",
            "\(tab3)return nib().instantiate(withOwner: nil, options: nil)[0] as! \(className)",
            "\(tab2)}",
            "",
            "\(tab1)}",
            "}",
            ].joined(separator: newLine)
    }
}
