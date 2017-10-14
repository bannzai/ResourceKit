//
//  ReusableResourceType.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

enum ReusableResourceType: String {
    case UITableViewCell
    case UICollectionViewCell
    
    init?(name: String) {
        switch name {
        case "tableViewCell": self = .UITableViewCell
        case "collectionViewCell": self = .UICollectionViewCell
        default: return nil
        }
    }
}
