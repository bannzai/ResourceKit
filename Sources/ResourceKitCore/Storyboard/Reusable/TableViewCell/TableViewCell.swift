//
//  TableViewCell.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

class TableViewCell: ReusableResource {
    let className: String
    var reusableIdentifiers: Set<String> = []
    
    init(reusableIdentifier: String, className: String) {
        self.reusableIdentifiers.insert(reusableIdentifier)
        self.className = className
    }
}
