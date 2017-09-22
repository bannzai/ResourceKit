//
//  LocalizedStringTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/22.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct LocalizedStringTranslator: Translator {
    func translate(for input: LocalizedString) throws -> LocalizedStringOutputer {
        return LocalizedStringOutputerImpl(localizedStrings: input.localizableStrings)
    }
}
