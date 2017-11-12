//
//  LocalizedStringOutputer.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/22.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public protocol LocalizedStringOutputer: Output {
    
}

public struct LocalizedStringOutputerImpl: LocalizedStringOutputer {
    let localizedStrings: [String: String]
    
    public var declaration: String {
        return [
            "extension String {",
            "\(Const.tab1)public struct Localized {",
            "\(generateLocalizableConstants().joined(separator: Const.newLine))",
            "\(Const.tab1)}",
            "}",
            ].joined(separator: Const.newLine)
    }
}

fileprivate extension LocalizedStringOutputerImpl {
    fileprivate func generateLocalizableConstants() -> [String] {
        func toConstantName(_ key: String) -> String {
            return key
                .replacingOccurrences(of: "[^a-z,^A-Z,^0-9]", with: "_", options: .regularExpression, range: nil)
                .replacingOccurrences(of: ",", with: "_", options: .regularExpression, range: nil)
            
        }
        return localizedStrings.keys.flatMap {
            return "\(Const.tab2)public static let \(toConstantName($0)) = NSLocalizedString(\"\($0)\", comment: \"\")"
        }
    }
}
