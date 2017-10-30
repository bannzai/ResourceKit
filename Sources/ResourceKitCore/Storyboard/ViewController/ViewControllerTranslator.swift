//
//  ViewControllerTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public struct ViewControllerTranslator: Translator {
    public let config: Config
    public init(
        config: Config
        ) {
        self.config = config
    }
    public func translate(for input: ViewController) throws -> ViewControllerOutput {
        return ViewControllerOutputImpl(
            name: input.name,
            storyboardInfos: input.storyboardInfos,
            hasSuperClass: input.superClass != nil,
            superClassStoryboardInfos: input.superClass?.storyboardInfos ?? [],
            config: config
        )
    }
}
