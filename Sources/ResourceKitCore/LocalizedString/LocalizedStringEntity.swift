//
//  LocalizedStringEntity.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/22.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public struct LocalizedString {
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
}
