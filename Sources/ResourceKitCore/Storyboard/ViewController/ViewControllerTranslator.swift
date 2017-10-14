//
//  ViewControllerTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct ViewControllerTranslator: Translator {
    let config: Config
    func translate(for input: ViewController) throws -> ViewControllerOutput {
        return ViewControllerOutputImpl(
            name: input.name,
            storyboardInfos: input.storyboardInfos,
            hasSuperClass: input.superClass != nil,
            superClassStoryboardInfos: input.superClass?.storyboardInfos ?? [],
            config: Config
        )
    }
}
