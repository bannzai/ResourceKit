//
//  XibTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public struct XibTranslator: Translator {
    public init() { }
    public func translate(for input: Xib) throws -> XibOutput {
        return XibOutputImpl(
            nibName: input.nibName,
            className: input.className
        )
    }
}
