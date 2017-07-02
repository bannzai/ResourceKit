//
//  xib.swift
//  o
//
//  Created by kingkong999yhirose on 2016/04/10.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

enum ReusableResourceType: String {
    case UITableViewCell
    case UICollectionViewCell
    
    init?(name: String) {
        switch name {
        case "tableViewCell": self = .UITableViewCell
        case "collectionViewCell": self = .UICollectionViewCell
        default: return nil
        }
    }
}

final class XibForView: Declaration {
    let nibName: String
    let className: String
    var isFilesOwner = false
    
    init(nibName: String, className: String) {
        self.nibName = nibName
        self.className = className
    }
    init(nibName: String, className: String, isFilesOwner: Bool) {
        self.nibName = nibName
        self.className = className
        self.isFilesOwner = isFilesOwner
    }
    
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

