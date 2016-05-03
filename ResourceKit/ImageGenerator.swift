//
//  ImageGenerator.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol Generattable {
    associatedtype GenerateType
    init(urls: [NSURL])
    func generate() -> GenerateType
}

struct Image: Generattable {
    let assets: Assets
    let resources: Resources
    
    init(urls: [NSURL]) {
        assets = Assets(urls: urls)
        resources = Resources(urls: urls)
    }
    
    static func imageFunction(withName: String) -> String {
        return "UIImage(named: \"\(withName)\")!"
    }
    
    func generate() -> Extension {
        return Extension(
            type: "UIImage",
            structs: [
                assets.generate(),
                resources.generate()
            ]
        )
    }
}

extension Image {
    struct Assets: Generattable {
        let imageNames: [String]
        
        init(urls: [NSURL]) {
            let xcassets = urls
                .filter { $0.pathExtension == "xcassets" }
                .flatMap {
                    NSFileManager
                        .defaultManager()
                        .enumeratorAtURL(
                            $0,
                            includingPropertiesForKeys: nil,
                            options: .SkipsHiddenFiles,
                            errorHandler: nil
                    )
            }
            
            imageNames = xcassets
                .flatMap { $0.flatMap { url in url as? NSURL }  }
                .filter { $0.pathExtension == "imageset"}
                .flatMap { $0.URLByDeletingPathExtension?.lastPathComponent }
        }
        
        func generate() -> Struct {
            return Struct(
                name: "Asset",
                lets: imageNames.flatMap {
                    Let(
                        isStatic: true,
                        name: $0,
                        type: "UIImage",
                        value: Image.imageFunction($0)
                    )
                }
            )
        }
    }
    
}

extension Image {
    struct Resources: Generattable {
        static let supportExtensions: Set<String> = [ "png", "jpg", "gif" ]
        let imageNames: [String]
        
        init(urls: [NSURL]) {
            imageNames = urls
                .filter { Resources.supportExtensions.contains($0.pathExtension ?? "") }
                .flatMap { $0.URLByDeletingPathExtension?.lastPathComponent }
                .flatMap { name -> String? in
                    let pattern = "@[0-9]x"
                    let regex = try! NSRegularExpression(pattern: pattern, options: .UseUnixLineSeparators)
                    let result = regex.matchesInString(name, options: [], range: NSMakeRange(0, name.characters.count)).first
                    
                    if result != nil {
                        return nil
                    }
                    return name
            }
        }
        
        func generate() -> Struct {
            return Struct(
                name: "Resource",
                lets: imageNames.flatMap {
                    Let(
                        isStatic: true,
                        name: $0,
                        type: "UIImage",
                        value: Image.imageFunction($0)
                    )
                }
            )
        }
    }
}