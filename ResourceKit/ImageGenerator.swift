//
//  ImageGenerator.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol ImageGenerator: Declaration {
    var begin: String { get }
    var body: String { get }
    var end: String { get }
    init(urls: [URL]) 
}

extension ImageGenerator {
    var declaration: String {
        return [begin, body, end].joined(separator: newLine)
    }
}

struct Image: ImageGenerator {
    let assets: Assets
    let resources: Resources
    
    init(urls: [URL]) {
        assets = Assets(urls: urls)
        resources = Resources(urls: urls)
    }
    
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
            return resources.declaration
        }
        if !config.image.projectResource {
            return assets.declaration
        }
        
        return assets.declaration + resources.declaration 
    }
    
    var end: String {
        return "}" + newLine
    }
}

extension Image {
    struct Assets: ImageGenerator {
        let imageNames: [String]
        
        init(urls: [URL]) {
            let xcassets = urls
                .filter { $0.pathExtension == "xcassets" }
                .flatMap {
                    FileManager.default
                        .enumerator(
                            at: $0,
                            includingPropertiesForKeys: nil,
                            options: .skipsHiddenFiles,
                            errorHandler: nil
                    )
            }
            
            imageNames = xcassets
                .flatMap { $0.flatMap { url in url as? URL }  }
                .filter { $0.pathExtension == "imageset"}
                .flatMap { $0.deletingPathExtension().lastPathComponent }
        }
        
        var begin: String {
            return "    \(accessControl) struct Asset {" 
        }
        var body: String {
            let body = imageNames
                .flatMap { "        \(accessControl) static let \($0): UIImage = \(Image.imageFunction($0))" }
                .joined(separator: newLine)
            return body + newLine
        }
        var end: String {
            return "}" + newLine
        }
    }
}

extension Image {
    struct Resources: ImageGenerator {
        static let supportExtensions: Set<String> = [ "png", "jpg", "gif" ]
        let imageNames: [String]
        
        init(urls: [URL]) {
            imageNames = urls
                .filter { Resources.supportExtensions.contains($0.pathExtension) }
                .flatMap { $0.deletingPathExtension().lastPathComponent }
                .flatMap { name -> String? in
                    let pattern = "@[0-9]x"
                    let regex = try? NSRegularExpression(pattern: pattern, options: .useUnixLineSeparators)
                    let result = regex?.matches(in: name, options: [], range: NSMakeRange(0, name.characters.count)).first
                    
                    if result != nil {
                        return nil
                    }
                    return name
            }
        }
        
        var begin: String {
            return "    \(accessControl) struct Resources {"
        }
        var body: String {
            let body = imageNames
                .flatMap { "        \(accessControl) static let \($0): UIImage = \(Image.imageFunction($0))" }
                .joined(separator: newLine)
            return body
        }
        var end: String {
            return "}" + newLine
        }
    }
}
