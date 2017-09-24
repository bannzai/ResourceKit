//
//  ReusableResource.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/04/07.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

protocol ReusableResource {
    var className: String { get }
    var reusableIdentifiers: Set<String> { get set }
}
