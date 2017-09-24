//
//  ReusableTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct ReusableTranslator: Translator {
    let accessControl: String
    
    func translate(for input: ReusableResource) throws -> ReusableResourceOutput {
        return ReusableResourceOutputImpl(
            accessControl: accessControl,
            className: input.className,
            reusableIdentifers: input.reusableIdentifiers
        )
    }
}
