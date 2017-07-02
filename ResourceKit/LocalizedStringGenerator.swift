//
//  LocalizedStringGenerator.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct LocalizedString: Declaration {
    let localizableStrings:[String: String]
    init(urls: [URL]) {
        let files = urls.filter { $0.lastPathComponent == "Localizable.strings" }
        
        let maximumLocalizableStringPairs =
            files.flatMap ({ NSDictionary(contentsOf: $0) })
                .sorted (by: { $0.count > $1.count })
                .first
        
        guard let localizableStrings = maximumLocalizableStringPairs as? [String: String] else {
            self.localizableStrings = [:]
            return
        }
        self.localizableStrings = localizableStrings
    }
    
    var declaration: String {
        return [
            "\(accessControl) extension String {",
            "   \(accessControl) struct Localized {",
            "       \(accessControl) struct Localized",
            "   }",
            "}",
            ].joined(separator: newLine)
    }
    
    fileprivate func generateLocalizableConstants() -> [String] {
        func toConstantName(_ key: String) -> String {
            return key
                .replacingOccurrences(of: "[^a-z,^A-Z,^0-9]", with: "_", options: .regularExpression, range: nil)
                .replacingOccurrences(of: ",", with: "_", options: .regularExpression, range: nil)
            
        }
        return localizableStrings.keys.flatMap {
            return "    \(accessControl) static let \(toConstantName($0)) = \"(NSLocalizedString(\"\($0)\", comment: \"\")"
        }
    }
}
