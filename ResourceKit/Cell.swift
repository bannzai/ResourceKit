//
//  cell.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/04/07.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

protocol ReusableResource: Declaration {
    var className: String { get }
    var reusableIdentifiers: [String] { get }
}

extension ReusableResource {
    var declaration: String {
        return [
            "\(accessControl) extension \(className) {",
            "   \(accessControl) struct ReusableImpl: Reusable {",
            "       \(accessControl) typealias View = \(className)",
            "       \(accessControl) let name: String = \"\(className)\"",
            "   }",
            "}",
        ].joined(separator: newLine)
    }
}

class TableViewCell: ReusableResource {
    let className: String
    private(set) var reusableIdentifiers: [String] = []
    
    init(reusableIdentifier: String, className: String) {
        self.reusableIdentifiers.append(reusableIdentifier)
        self.className = className
    }
}

class CollectionViewCell: ReusableResource {
    let className: String
    private(set) var reusableIdentifiers: [String] = []
    
    init(reusableIdentifier: String, className: String) {
        self.reusableIdentifiers.append(reusableIdentifier)
        self.className = className
    }
}

