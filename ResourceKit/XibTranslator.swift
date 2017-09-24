//
//  XibTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct XibTranslator: Translator {
    let accessControl: String
    
    func translate(for input: Xib) throws -> XibOutput {
        return XibOutputImpl(
            accessControl: accessControl,
            nibName: input.nibName,
            className: input.className
        )
    }
}
