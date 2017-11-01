//
//  ReusableTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public struct ReusableTranslator: Translator {
    public init() { }
    public func translate(for input: ReusableResource) throws -> ReusableResourceOutput {
        return ReusableResourceOutputImpl(
            className: input.className,
            reusableIdentifers: input.reusableIdentifiers
        )
    }
}
