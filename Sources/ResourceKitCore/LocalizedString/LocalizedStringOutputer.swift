//
//  LocalizedStringOutputer.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/22.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol LocalizedStringOutputer: Output {
    
}

struct LocalizedStringOutputerImpl: LocalizedStringOutputer {
    let localizedStrings: [String: String]
    
    var declaration: String {
        return [
            "extension String {",
            "\(tab1)struct Localized {",
            "\(generateLocalizableConstants().joined(separator: newLine))",
            "\(tab1)}",
            "}",
            ].joined(separator: newLine)
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
            return "\(tab2)static let \(toConstantName($0)) = NSLocalizedString(\"\($0)\", comment: \"\")"
        }
    }
}
