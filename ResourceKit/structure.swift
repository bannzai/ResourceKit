//
// Structure.swift
// ResourceKit
//
//  Created by Hirose.Yudai on 2016/04/07.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

protocol Structure {
    var declaration: String { get }
}

struct Body: Structure {
    let body: [String]
    
    init(_ body: [String]) {
        self.body = body
    }
    
    init(_ oneline: String) {
        self.body = [oneline]
    }
    
    var declaration: String {
        return body.flatMap { indent + $0 }.joined(separator: newLine + indent)
    }
}

struct Argument: Structure {
    let name: String
    let type: String
    let defaultValue: String
    
    init(name: String, type: String, defaultValue: String = "") {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
    
    func generateDefault() -> String {
        return defaultValue.isEmpty ? "" : " = " + defaultValue
    }
    
    static func generateDeclaration(_ arguments: [Argument]) -> String {
        if arguments.isEmpty {
            return "()"
        }
        let args = arguments.flatMap {
            "\($0.name): \($0.type)\($0.generateDefault())"
        }.joined(separator: ", ")
        return "(\(args))"
    }
    
    var declaration: String {
        return "\(name): \(type)"
    }
}

struct Function: Structure {
    let head: String
    let name: String
    let arguments: [Argument]
    let returnType: String
    let body: Body
    
    fileprivate var isDummy = false
    static func dummyFunction() -> Function {
        return Function()
    }
    
    fileprivate init() {
        self.head = ""
        self.name = ""
        self.arguments = []
        self.returnType = ""
        self.body = Body("")
        self.isDummy = true
    }
    
    init(
        head: String = "internal",
        name: String,
        arguments: [Argument],
        returnType: String,
        body: Body
        ) {
        self.head = head
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
        self.body = body
    }
    
    var argumentsDeclaration: String {
        return Argument.generateDeclaration(arguments)
    }
    
    var declaration: String {
        if isDummy {
            return ""
        }
        return [
            "\(head) func \(name)\(argumentsDeclaration) -> \(returnType) {",
            body.declaration,
            "}"
        ].joined(separator: lineAndIndent)
    }
}

struct Extension: Structure {
    let type: String
    let functions: [Function]
    let structs: [Struct]
    
    init(type: String, functions: [Function] = [], structs: [Struct] = []) {
        self.type = type
        self.functions = functions
        self.structs = structs
    }
    
    var declaration: String {
        return [
            "extension \(type) { ",
            functions.flatMap { $0.declaration }.joined(separator: lineAndIndent),
            structs.flatMap { $0.declaration }.joined(separator: lineAndIndent)
        ].joined(separator: lineAndIndent) + " \(newLine)} \(newLine)"
    }
}

struct Enum: Structure {
    let name: String
    let elements: [String]
    
    var declaration: String {
        return [
            "enum \(name) { ",
            elements.flatMap { "\(indent)case \($0)" }.joined(separator: newLine),
            "} \(newLine)"
        ].joined(separator: newLine)
    }
    
    func caseParagraph(_ caseString: (String) -> String) -> String {
        return [
            "switch \(name) {" ,
            elements.flatMap { 
                ["\(indent)case \($0): ", caseString($0)].joined(separator: newLine)
                }.joined(separator: newLine),
            "}\(newLine)"
        ].joined(separator: newLine)
    }
}

struct Struct: Structure {
    let name: String
    let _protocol :String
    let lets: [Let]
    let functions: [Function]
    
    init(name: String, _protocol: String = "" ,lets: [Let] = [], functions: [Function] = []) {
        self.name = name
        self._protocol = _protocol
        self.lets = lets
        self.functions = functions
    }
    
    func generateProtocol() -> String {
        return _protocol.isEmpty ? "" : ": \(_protocol)"
    }
    
    var declaration: String {
        return [
            "struct \(name)\(generateProtocol()) {",
            lets.flatMap { indent + $0.declaration }.joined(separator: lineAndIndent),
            functions.flatMap { indent + $0.declaration }.joined(separator: lineAndIndent),
            "}"
        ].joined(separator: lineAndIndent)
    }
}

struct Class: Structure {
    let name: String
    let functions: [Function]
    
    var declaration: String {
        return [
        "class \(name) { ",
            functions
                .flatMap { $0.declaration }
                .joined(separator: newLine),
            "}"
        ].joined(separator: newLine)
    }
}

struct Let: Structure {
    let isStatic: Bool
    let name: String
    let type: String
    let value: String
    let isConvertStringValue: Bool
    
    init(isStatic: Bool = false, name: String, type: String, value: String, isConvertStringValue: Bool = false) {
        self.isStatic = isStatic
        self.name = name
        self.type = type
        self.value = value
        self.isConvertStringValue = isConvertStringValue
    }
    
    var letType: String {
        return isStatic ? "static let" : "let"
    }
    
    var declaration: String {
        if isConvertStringValue {
            return "\(letType) \(name): \(type) = \"\(value)\""
        }
        return "\(letType) \(name): \(type) = \(value)"
    }
}

struct Var: Structure {
    let isStatic: Bool
    let name: String
    let type: String
    let value: String
    
    init(isStatic: Bool = false, name: String, type: String, value: String = "") {
        self.isStatic = isStatic
        self.name = name
        self.type = type
        self.value = value
    }
    
    var varType: String {
        return isStatic ? "static var" : "var"
    }
    
    func generateValue() -> String {
        return value.isEmpty ? "" : " = \"\(value)\""
    }
    
    var declaration: String {
        return "\(varType) \(name): \(type)\(generateValue())"
    }
}

struct FunctionForProtocol: Structure {
    let head: String
    let name: String
    let arguments: [Argument]
    let returnType: String
    
    init(
        head: String = "internal",
        name: String,
        arguments: [Argument],
        returnType: String
        ) {
        self.head = head
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
    }
    
    var argumentsDeclaration: String {
        return Argument.generateDeclaration(arguments)
    }
    
    var declaration: String {
        return "\(head) func \(name)\(argumentsDeclaration) -> \(returnType)"
    }
}

struct Protocol: Structure {
    let name: String
    var getters: [Var]
    var functions: [FunctionForProtocol]
    
    var declaration: String {
        return [
            "protocol \(name) {",
            getters.flatMap { indent + $0.declaration + " { get } "}.joined(separator: newLine),
            functions.flatMap { indent + $0.declaration }.joined(separator: newLine),
            "}"
        ].joined(separator: newLine)
    }
    
    
}
