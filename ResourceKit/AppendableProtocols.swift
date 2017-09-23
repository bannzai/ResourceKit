//
//  AppendableProtocols.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/23.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol AppendableForPaths: class {
    func appendFileReferencePaths(urls: [URL])
    func appendLocalizedPaths(urls: [URL])
}

protocol AppendableForXibs: class {
    func appendXibForView(_ xib: XibForView)
}

protocol AppendableForStoryboard: class {
    func appendTableViewCell(_ className: String, reusableIdentifier: String)
    func appendCollectionViewCell(_ className: String, reusableIdentifier: String)
    func appendViewControllerInfoReference(_ className: String, viewControllerInfo: ViewControllerInfoOfStoryboard)
}
