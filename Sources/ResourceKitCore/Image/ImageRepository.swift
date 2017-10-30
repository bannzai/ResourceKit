//
//  ImageRepository.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/08/09.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public protocol ImageAssetRepository {
    func load() -> Image.Assets
}

public struct ImageAssetRepositoryImpl: ImageAssetRepository {
    public init() { }
    public func load() -> Image.Assets {
        return Image.Assets(urls:
            ProjectResource
            .shared
            .paths
        )
    }
}

public protocol ImageResourcesRepository {
    func load() -> Image.Resources
}

public struct ImageResourcesRepositoryImpl: ImageResourcesRepository {
    public init() { }
    public func load() -> Image.Resources {
        return Image.Resources(urls:
            ProjectResource
                .shared
                .paths
        )
    }
}



