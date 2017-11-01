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
    public let viewControllers: [ViewController]
    
    public init(
        config: Config,
        viewControllers: [ViewController]
        ) {
        self.config = config
        self.viewControllers = viewControllers
    }
    
    func superClass(for viewController: ViewController) -> ViewController? {
        return viewControllers
            .filter ({ $0.className == viewController.superClassName })
            .first
    }

    public func translate(for input: ViewController) throws -> ViewControllerOutput {
        let superClassViewController = superClass(for: input)
        return ViewControllerOutputImpl(
            name: input.name,
            storyboardInfos: input.storyboardInfos,
            hasSuperClass: superClassViewController != nil,
            superClassStoryboardInfos: superClassViewController?.storyboardInfos ?? [],
            config: config
        )
    }
}
