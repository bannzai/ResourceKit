//
//  AccessControlType.swift
//  ResourceKit
//
//  Created by 廣瀬雄大 on 2017/07/03.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

enum AccessControlType: String {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
    case `open`
    
    init(from string: String) {
        guard let accessControlType = AccessControlType(rawValue: string) else {
            self = .internal
            return
        }
        
        self = accessControlType
    }
    
    var canOverride: Bool {
        switch self {
        case .private, .fileprivate:
            return false
        case .internal, .open, .public:
            return true
        }
    }
}
