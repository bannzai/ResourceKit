//
//  Xib.swift
//  o
//
//  Created by kingkong999yhirose on 2016/04/10.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

struct Xib {
    let nibName: String
    let className: String
    let isFilesOwner: Bool
    
    init(nibName: String, className: String, isFilesOwner: Bool) {
        self.nibName = nibName
        self.className = className
        self.isFilesOwner = isFilesOwner
    }
}

