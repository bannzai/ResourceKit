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
            "   \(accessControl) struct XibImpl: Xib {",
            "       \(accessControl) typealias View = \(className)",
            "       \(accessControl) let name: String = \"\(className)\"",
            "       ",
            "       \(accessControl) func nib() -> UINib {",
            "           return UINib(nibName: \"\(nibName)\", bundle: Bundle(for: \(className).classForCoder()))",
            "       }",
            "",
            "       \(accessControl) func view() -> \(className) {",
            "           return nib().instantiate(withOwner: nil, options: nil)[0] as! \(className)",
            "       }",
            "",
            "   }",
            "}",
            ].joined(separator: newLine)
    }
}

