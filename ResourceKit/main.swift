//
//  main.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/01/27.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation
private let RESOURCE_FILENAME = "Resource.generated.swift"
private let env = ProcessInfo().environment
let debug = env["DEBUG"] != nil
let defaultAccessControl: String = "public"
let accessControl = defaultAccessControl

private func extractGenerateDir() -> String? {
    return ProcessInfo
        .processInfo
        .arguments
        .flatMap { arg in
            guard let range = arg.range(of: "-p ") else {
                return nil
            }
            return arg.substring(from: range.upperBound)
        }
        .last
}

if !debug {
    do {
        try Environment.verifyUseEnvironment()
    } catch {
        exit(1)
    }
}

let debugOutputPath = env["DEBUG_OUTPUT_PATH"]
let outputPath = debugOutputPath ?? extractGenerateDir() ?? Environment.SRCROOT.element
let config: Config = Config()

do {
    let outputUrl = URL(fileURLWithPath: outputPath)
    var resourceValue: AnyObject?
    try (outputUrl as NSURL).getResourceValue(&resourceValue, forKey: URLResourceKey.isDirectoryKey)
    
    let writeUrl: URL
    writeUrl = outputUrl.appendingPathComponent(RESOURCE_FILENAME, isDirectory: false)

    func imports() -> [String] {
        
        guard let content = try? String(contentsOf: writeUrl) else {
            return config.segue.addition ? ["import UIKit", "import SegueAddition"] : ["import UIKit"]
        }
        let pattern = "\\s*import\\s+.+"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .useUnixLineSeparators) else {
            return ["import UIKit"]
        }
        let results = regex.matches(in: content, options: [], range: NSMakeRange(0, content.characters.count))
        
        if results.isEmpty {
            return config.segue.addition ? ["import UIKit", "import SegueAddition"] : ["import UIKit"]
        }
        
        return results.flatMap { (result) -> String? in
            if result.range.location != NSNotFound {
                let matchingString = (content as NSString).substring(with: result.range) as String
                return matchingString
                    .replacingOccurrences(of: "\n", with: "")
            }
            return nil
        }
    }
    
    
    let projectFilePath = env["DEBUG_PROJECT_FILE_PATH"] != nil ? URL(fileURLWithPath: env["DEBUG_PROJECT_FILE_PATH"]!) : Environment.PROJECT_FILE_PATH.path
    let projectTarget = env["DEBUG_TARGET_NAME"] ?? Environment.TARGET_NAME.element
    let parser = try ProjectResourceParser(xcodeURL: projectFilePath, target: projectTarget)
    let paths = parser.paths.filter { $0.pathExtension != nil }
    
    paths
        .filter { $0.pathExtension == "storyboard" }
        .forEach { let _ = try? StoryboardParser(url: $0) }
    
    paths
        .filter { $0.pathExtension == "xib" }
        .forEach { let _ = try? XibPerser(url: $0) }
    
    let importsContent = imports().joined(separator: newLine)
    
    let reusableProtocolContent: String = [
        "\(accessControl) protocol Xib {",
        "   associatedtype View",
        "   var name: String { get }",
        "}",
    ].joined(separator: newLine)
    
    let xibProtocolContent: String = [
        "\(accessControl) protocol Xib: Reusable {",
        "   func nib() -> UINib",
        "   func view() -> View",
        "}",
    ].joined(separator: newLine)
    
    let tableViewExtensionContent: String = [
        "\(accessControl) extension UITableView {",
        "    \(accessControl) func register<X: Xib>(xib: X) -> Void where X.View: UITableViewCell {",
        "        register(xib.nib(), forCellReuseIdentifier: xib.name)",
        "    }",
        "    ",
        "    \(accessControl) func register<X: >(xibs: [X]) -> Void where X.View: UITableViewCell {",
        "        xibs.forEach { register(xib: $0) }",
        "    }",
        "    ",
        "    \(accessControl) func dequeueReusableCell<X: Reusable>(with xib: X, for indexPath: IndexPath) -> X.View where X.View: UITableViewCell {",
        "        return dequeueReusableCell(withIdentifier: xib.name, for: indexPath) as! X.View",
        "    }",
        "}",
        ].joined(separator: newLine)
    
    let collectionViewExtensionContent = [
        "\(accessControl) extension UICollectionView {",
        "    \(accessControl) func register<X: Xib>(xib: X) -> Void where X.View: UICollectionViewCell {",
        "        register(xib.nib(), forCellReuseIdentifier: xib.name)",
        "    }",
        "    ",
        "    \(accessControl) func register<X: Xib>(xibs: [X]) -> Void where X.View: UICollectionViewCell {",
        "        xibs.forEach { register(xib: $0) }",
        "    }",
        "    ",
        "    \(accessControl) func dequeueReusableCell<X: Reusable>(with xib: X, for indexPath: IndexPath) -> X.View where X.View: UICollectionViewCell {",
        "        return dequeueReusableCell(withIdentifier: xib.name, for: indexPath) as! X.View",
        "    }",
        "}",
    ].joined(separator: newLine)
    
    let viewControllerContent = ProjectResource.sharedInstance.viewControllers
        .flatMap { $0.declaration }
        .joined(separator: newLine)
    
    let tableViewCellContent: String
    let collectionViewCellContent: String
    
    if config.reusable.identifier {
        tableViewCellContent = ProjectResource.sharedInstance.tableViewCells
            .flatMap { $0.declaration }
            .joined(separator: newLine)
        
        collectionViewCellContent = ProjectResource.sharedInstance.collectionViewCells
            .flatMap { $0.declaration }
            .joined(separator: newLine)
        
    } else {
        tableViewCellContent = ""
        collectionViewCellContent = ""
    }
    
    let xibContent: String
    if config.nib.xib {
        xibContent = ProjectResource.sharedInstance.xibs
            .flatMap { $0.declaration }
            .joined(separator: newLine)
    } else {
        xibContent = ""
    }
    
    let imageContent = Image(urls: paths).declaration + newLine
    
    let stringContent: String
    
    if config.string.localized {
        stringContent = LocalizedString(urls: parser.localizablePaths).declaration + newLine
    } else {
        stringContent = ""
    }
    
    let content = (
        Header
            + importsContent + newLine
            + xibProtocolContent
            + tableViewExtensionContent
            + collectionViewExtensionContent
            + viewControllerContent
            + tableViewCellContent
            + collectionViewCellContent
            + xibContent
            + imageContent
            + stringContent
    )
    
    func write(_ code: String, fileURL: URL) throws {
        try code.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
    }
    
    try write(content, fileURL: writeUrl)
} catch {
    if let e = error as? ResourceKitErrorType {
        print(e.description())
        
    } else {
        print(error)
    }
    
    exit(3)
}
