//
//  ImageOutputer.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/08/09.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation


protocol ImageOutputer: Output {
    var begin: String { get }
    var body: String { get }
    var end: String { get }
}

extension ImageOutputer {
    var declaration: String {
        return [begin, body, end].joined(separator: newLine)
    }
}

struct ImageOutputerImpl: ImageOutputer {
    let assetsOutputer: ImageOutputer
    let resourcesOutputer: ImageOutputer 
    
    static func imageFunction(_ withName: String) -> String {
        return "UIImage(named: \"\(withName)\")!"
    }
    
    var begin: String {
        return "\(accessControl) extension UIImage {" + newLine
    }
    
    var body: String {
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
        
        return assetsOutputer.declaration + resourcesOutputer.declaration
    }
    
    var end: String {
        return "}" + newLine
    }
}

extension ImageOutputerImpl {
    struct AssetsOutputer: ImageOutputer {
        let imageNames: [String]
        
        var begin: String {
            return "\(tab1)\(accessControl) struct Asset {" 
        }
        var body: String {
            let body = imageNames
                .flatMap { "\(tab2)\(accessControl) static let \($0): UIImage = \(ImageOutputerImpl.imageFunction($0))" }
                .joined(separator: newLine)
            return body + newLine
        }
        var end: String {
            return "\(tab1)}" + newLine
        }
    }
}

extension ImageOutputerImpl {
    struct ResourcesOutputer: ImageOutputer {
        let imageNames: [String]
        
        var begin: String {
            return "\(tab1)\(accessControl) struct Resource {"
        }
        var body: String {
            let body = imageNames
                .flatMap { "\(tab2)\(accessControl) static let \($0): UIImage = \(ImageOutputerImpl.imageFunction($0))" }
                .joined(separator: newLine)
            return body
        }
        var end: String {
            return "\(tab1)}" + newLine
        }
    }
}
