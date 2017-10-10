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
let config: Config = ConfigImpl()

do {
    let outputUrl = URL(fileURLWithPath: outputPath)
    var resourceValue: AnyObject?
    try (outputUrl as NSURL).getResourceValue(&resourceValue, forKey: URLResourceKey.isDirectoryKey)
    
    let writeUrl: URL = outputUrl.appendingPathComponent(RESOURCE_FILENAME, isDirectory: false)
    
    let projectFilePath = env["DEBUG_PROJECT_FILE_PATH"] != nil ? URL(fileURLWithPath: env["DEBUG_PROJECT_FILE_PATH"]!) : Environment.PROJECT_FILE_PATH.path
    let projectTarget = env["DEBUG_TARGET_NAME"] ?? Environment.TARGET_NAME.element
    let parser = try ProjectResourceParser(xcodeURL: projectFilePath, target: projectTarget, writeResource: ProjectResource.shared)
    let paths = ProjectResource.shared.paths
    
    paths
        .filter { $0.pathExtension == "storyboard" }
        .forEach { try? StoryboardParserImpl(url: $0, writeResource: ProjectResource.shared).parse() }
    
    paths
        .filter { $0.pathExtension == "xib" }
        .forEach { try? XibPerserImpl(url: $0, writeResource: ProjectResource.shared).parse() }
    
    let importsContent = ImportOutputImpl(writeUrl: writeUrl).declaration
    
    let viewControllerContent = try ProjectResource
        .shared
        .viewControllers
        .map { (viewController) in
            try ViewControllerTranslator().translate(for: viewController).declaration
        }
        .joined(separator: newLine)
    
    let tableViewCellContent: String
    let collectionViewCellContent: String
    
    if config.reusable.identifier {
        tableViewCellContent = try ProjectResource.shared.tableViewCells
            .flatMap { try ReusableTranslator().translate(for: $0).declaration + newLine }
            .joined(separator: newLine)
            .appendNewLineIfNotEmpty()
        
        collectionViewCellContent = try ProjectResource.shared.collectionViewCells
            .flatMap { try ReusableTranslator().translate(for: $0).declaration + newLine }
            .joined(separator: newLine)
            .appendNewLineIfNotEmpty()
        
    } else {
        tableViewCellContent = ""
        collectionViewCellContent = ""
    }
    
    let xibContent: String
    if config.nib.xib {
        xibContent = try ProjectResource.shared.xibs
            .flatMap { try XibTranslator().translate(for: $0).declaration }
            .joined(separator: newLine)
            .appendNewLineIfNotEmpty()
    } else {
        xibContent = ""
    }
    
    let imageContent = try ImageTranslator().translate(
        for: (
            assets: ImageAssetRepositoryImpl().load(),
            resources: ImageResourcesRepositoryImpl().load())
        )
        .declaration
    
    let stringContent: String
    
    if config.string.localized {
        stringContent = try LocalizedStringTranslator()
            .translate(
                for: LocalizedStringRepositoryImpl(urls: ProjectResource.shared.localizablePaths).load()
            )
            .declaration
    } else {
        stringContent = ""
    }
    
    let content = (
        Header
            + importsContent + newLine
            + ExtensionsOutputImpl().reusableProtocolContent + newLine + newLine
            + ExtensionsOutputImpl().xibProtocolContent + newLine + newLine
            + ExtensionsOutputImpl().tableViewExtensionContent + newLine + newLine
            + ExtensionsOutputImpl().collectionViewExtensionContent + newLine + newLine
            + viewControllerContent + newLine
            + tableViewCellContent + newLine
            + collectionViewCellContent + newLine
            + xibContent + newLine
            + imageContent + newLine
            + stringContent + newLine
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
