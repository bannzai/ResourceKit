//
//  ImageRepository.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/08/09.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol ImageAssetRepository {
    func load() -> Image.Assets
}

struct ImageAssetRepositoryImpl: ImageAssetRepository {
    func load() -> Image.Assets {
        return Image.Assets(urls:
            ProjectResource
            .shared
            .paths
        )
    }
}

protocol ImageResourcesRepository {
    func load() -> Image.Resources
}

struct ImageResourcesRepositoryImpl: ImageResourcesRepository {
    func load() -> Image.Resources {
        return Image.Resources(urls:
            ProjectResource
                .shared
                .paths
        )
    }
}



