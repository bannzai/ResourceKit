//
//  ImageTranslator.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/08/09.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct ImageTranslator: Translator {
    typealias Input = (assets: Image.Assets, resources: Image.Resources)
    typealias Output = ImageOutputer
    
    func translate(for input: Input) throws -> Output {
        return ImageOutputerImpl(
            assetsOutputer: try ImageAssetsTranslator().translate(for: input.assets),
            resourcesOutputer: try ImageeResourcesTranslator().translate(for: input.resources)
        )
    }
}

struct ImageAssetsTranslator: Translator {
    func translate(for input: Image.Assets) throws -> ImageOutputer {
        return ImageOutputerImpl.AssetsOutputer(imageNames: input.imageNames)
    }
}

struct ImageeResourcesTranslator: Translator {
    func translate(for input: Image.Resources) throws -> ImageOutputer {
        return ImageOutputerImpl.ResourcesOutputer(imageNames: input.imageNames)
    }
}
