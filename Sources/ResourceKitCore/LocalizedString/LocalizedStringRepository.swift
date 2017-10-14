//
//  LocalizedStringRepository.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/22.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol LocalizedStringRepository {
    func load() -> LocalizedString
}

struct LocalizedStringRepositoryImpl: LocalizedStringRepository {
    let urls: [URL]
    func load() -> LocalizedString {
        return LocalizedString(urls: urls)
    }
}
