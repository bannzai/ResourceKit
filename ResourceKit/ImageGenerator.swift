//
//  ImageGenerator.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol Generatortable {
    init(urls: [NSURL])
}

final class Image {
    let assets = [Assets]()
    let resources = [Resources]()
}

extension Image {
    final class Assets: Generatortable {
        let imageNames: [String]
        init(urls: [NSURL]) {
            imageNames = urls
                .filter { $0.pathExtension == "xcassets"}
                .flatMap { $0.URLByDeletingPathExtension?.lastPathComponent }
                .flatMap { name -> String? in
                    return ""
            }
        }
    }
}

extension Image {
    final class Resources: Generatortable {
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
    }
}