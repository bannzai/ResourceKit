//
//  xib.swift
//  o
//
//  Created by kingkong999yhirose on 2016/04/10.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

enum ReusableResource: String {
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
    let name: String
    let className: String
    var isFilesOwner = false
    
    init(name: String, className: String) {
        self.name = name
        self.className = className
    }
    init(name: String, className: String, isFilesOwner: Bool) {
        self.name = name
        self.className = className
        self.isFilesOwner = isFilesOwner
    }
    
    var declaration: String {
        [
        "struct "
        
        ]
        "let name: String = \"\(className)\"",
        return ""
    }
    
    
    func generateExtension() -> Extension {
        return Extension(
            type: className,
            structs: generateStructs()
        )
    }
    
    func generateLets() -> [Let] {
        return [generateLet()]
    }
    
    func generateLet() -> Let {
        return Let(
            isStatic: false,
            name: "name",
            type: "String",
            value: className,
            isConvertStringValue: true
        )
    }
    
    func generateStruct() -> Struct {
        return Struct(
            name: "Xib",
            _protocol: "XibProtocol",
            lets: generateLets(),
            functions: functions()
        )
    }
    
    func generateStructs() -> [Struct] {
        if className.isEmpty {
            return []
        }
        return [generateStruct()]
    }
    
    func functions() -> [Function] {
        if isFilesOwner {
            return [filesOwnerFunction()]
        }
        return [
            nib(),
            view()
        ]
    }
    
    func filesOwnerFunction() -> Function {
        return Function(
            head: "internal",
            name: "instance",
            arguments: [],
            returnType: className,
            body: Body(
                "return \(className)(nibName: \"\(name)\", bundle: nil) "
            )
        )
    }
    
    func nib() -> Function {
        return Function(
            head: "internal",
            name: "nib",
            arguments: [],
            returnType: "UINib",
            body: Body(
                "return UINib(nibName: \"\(name)\", bundle: nil) "
            )
        )
    }
    
    func view() -> Function {
        return Function(
            head: "internal",
            name: "view",
            arguments: [],
            returnType: className,
            body: Body(
                "return nib().instantiate(withOwner: nil, options: nil)[0] as! \(className)"
            )
        )
    }
    
}

