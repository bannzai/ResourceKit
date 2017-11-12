//
//  XibOutput.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public protocol XibOutput: Output {
    
}

public struct XibOutputImpl: XibOutput {
    let nibName: String
    let className: String
    
    public var declaration: String {
        return [
            "extension \(className) {",
            "\(Const.tab1)public struct Xib: XibProtocol {",
            "\(Const.tab2)public typealias View = \(className)",
            "\(Const.tab2)public static let name: String = \"\(className)\"",
            "       ",
            "\(Const.tab2)public static func nib() -> UINib {",
            "\(Const.tab3)return UINib(nibName: \"\(nibName)\", bundle: Bundle(for: \(className).classForCoder()))",
            "\(Const.tab2)}",
            "",
            "\(Const.tab2)public static func view() -> \(className) {",
            "\(Const.tab3)return nib().instantiate(withOwner: nil, options: nil)[0] as! \(className)",
            "\(Const.tab2)}",
            "",
            "\(Const.tab1)}",
            "}",
            ].joined(separator: Const.newLine)
    }
}
