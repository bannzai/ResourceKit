//
//  LocalizedStringRepository.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/22.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public protocol LocalizedStringRepository {
    func load() -> LocalizedString
}

public struct LocalizedStringRepositoryImpl: LocalizedStringRepository {
    public let urls: [URL]
    public init(
        urls: [URL]
        ) {
        self.urls = urls
    }
    public func load() -> LocalizedString {
        return LocalizedString(urls: urls)
    }
}
