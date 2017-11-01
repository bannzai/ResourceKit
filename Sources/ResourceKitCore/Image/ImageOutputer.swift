//
//  ImageOutputer.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/08/09.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation


public protocol ImageOutputer: Output {
    var begin: String { get }
    var body: String { get }
    var end: String { get }
}

public extension ImageOutputer {
    var declaration: String {
        return [begin, body, end].joined(separator: Const.newLine)
    }
}

public struct ImageOutputerImpl: ImageOutputer {
    let assetsOutputer: ImageOutputer
    let resourcesOutputer: ImageOutputer
    let config: Config
    
    static func imageFunction(_ withName: String) -> String {
        return "UIImage(named: \"\(withName)\")!"
    }
    
    public var begin: String {
        return "extension UIImage {"
    }
    
    public var body: String {
        guard
            config.image.assetCatalog || config.image.projectResource
            else {
                return ""
        }
        if !config.image.assetCatalog {
            return resourcesOutputer.declaration
        }
        if !config.image.projectResource {
            return assetsOutputer.declaration
        }
        
        return assetsOutputer.declaration
            + Const.newLine
            + resourcesOutputer.declaration
    }
    
    public var end: String {
        return "}" + Const.newLine
    }
}

extension ImageOutputerImpl {
    public struct AssetsOutputer: ImageOutputer {
        let imageNames: [String]
        
        public var begin: String {
            return "\(Const.tab1)struct Asset {" 
        }
        public var body: String {
            let body = imageNames
                .flatMap { "\(Const.tab2)static let \($0): UIImage = \(ImageOutputerImpl.imageFunction($0))" }
                .joined(separator: Const.newLine)
            return body 
        }
        public var end: String {
            return "\(Const.tab1)}" + Const.newLine
        }
    }
}

extension ImageOutputerImpl {
    public struct ResourcesOutputer: ImageOutputer {
        let imageNames: [String]
        
        public var begin: String {
            return "\(Const.tab1)struct Resource {"
        }
        public var body: String {
            let body = imageNames
                .flatMap { "\(Const.tab2)static let \($0): UIImage = \(ImageOutputerImpl.imageFunction($0))" }
                .joined(separator: Const.newLine)
            return body
        }
        public var end: String {
            return "\(Const.tab1)}" + Const.newLine
        }
    }
}
