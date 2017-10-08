//
//  ImageEntity.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/08/09.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct Image {
//    let assets: Assets
//    let resources: Resources
//    
//    init(urls: [URL]) {
//        assets = Assets(urls: urls)
//        resources = Resources(urls: urls)
//    }
}

extension Image {
    struct Assets {
        let imageNames: [String]
        
        init(urls: [URL]) {
            let xcassets = urls
                .filter { $0.pathExtension == "xcassets" }
                .flatMap {
                    FileManager
                        .default
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
        
    }
}

extension Image {
    struct Resources {
        static let supportExtensions: Set<String> = [ "png", "jpg", "gif" ]
        let imageNames: [String]
        
        init(urls: [URL]) {
            imageNames = urls
                .filter { Resources.supportExtensions.contains($0.pathExtension) }
                .flatMap { $0.deletingPathExtension().lastPathComponent }
                .flatMap { name -> String? in
                    // find @2x, @3x pattern
                    let pattern = "@[0-9]x"
                    let regex = try? NSRegularExpression(pattern: pattern, options: .useUnixLineSeparators)
                    let result = regex?.matches(in: name, options: [], range: NSMakeRange(0, name.characters.count)).first
                    
                    // if not exists, return is not value
                    if result != nil {
                        return nil
                    }
                    return name
            }
        }
    }
}
