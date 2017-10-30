//
//  ImageTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/08/09.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public struct ImageTranslator: Translator {
    public typealias Input = (assets: Image.Assets, resources: Image.Resources)
    public typealias Output = ImageOutputer
    
    let config: Config

    public init(
        config: Config
        ) {
        self.config = config
    }
    
    public func translate(for input: Input) throws -> Output {
        return ImageOutputerImpl(
            assetsOutputer: try ImageAssetsTranslator().translate(for: input.assets),
            resourcesOutputer: try ImageeResourcesTranslator().translate(for: input.resources),
            config: config
        )
    }
}

public struct ImageAssetsTranslator: Translator {
    public init() { }
    public func translate(for input: Image.Assets) throws -> ImageOutputer {
        return ImageOutputerImpl.AssetsOutputer(imageNames: input.imageNames)
    }
}

public struct ImageeResourcesTranslator: Translator {
    public init() { }
    public func translate(for input: Image.Resources) throws -> ImageOutputer {
        return ImageOutputerImpl.ResourcesOutputer(imageNames: input.imageNames)
    }
}
