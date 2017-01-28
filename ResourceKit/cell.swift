//
//  Cell.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/04/07.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

class TableViewCell {
    let className: String
    var reusableIdentifiers: [String] = []
    
    init(reusableIdentifier: String, className: String) {
        self.reusableIdentifiers.append(reusableIdentifier)
        self.className = className
    }
}

class CollectionViewCell {
    let className: String
    var reusableIdentifiers: [String] = []
    
    init(reusableIdentifier: String, className: String) {
        self.reusableIdentifiers.append(reusableIdentifier)
        self.className = className
    }
}

extension TableViewCell {
    func generateExtension() -> Extension {
        return Extension (
            type: className,
            structs: [generateStruct()]
        )
    }
    
    func generateStruct() -> Struct {
        return Struct(
            name: "Reusable",
            lets:
            reusableIdentifiers.flatMap {
                Let(
                    isStatic: true,
                    name: $0,
                    type: "String",
                    value: $0,
                    isConvertStringValue: true
                )
            }
        )
    }
}

extension CollectionViewCell {
    func generateExtension() -> Extension {
        return Extension (
            type: className,
            structs: [generateStruct()]
        )
    }
    
    func generateStruct() -> Struct {
        return Struct(
            name: "Reusable",
            lets:
            reusableIdentifiers.flatMap {
                Let(
                    isStatic: true,
                    name: $0,
                    type: "String",
                    value: $0,
                    isConvertStringValue: true
                )
            }
        )
    }
}

