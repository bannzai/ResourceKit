//
//  main.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/01/27.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//
import Foundation
import XcodeProject
import ResourceKitCore
import Commander

let projectFilePath = ResourceKitConfig.Debug.projectFilePath != nil ? ResourceKitConfig.Debug.projectFilePath! : Environment.PROJECT_FILE_PATH.rawValue
let main = command(
    Option<String>("project-file-path", default: projectFilePath)
) { projectFilePath in
    if !ResourceKitConfig.Debug.isDebug {
        do {
            try Environment.verifyUseEnvironment()
        } catch {
            print("verify use environtment")
            exit(1)
        }
    }
    
    let outputPath = ResourceKitConfig.outputPath
    let config: Config = ConfigImpl(outputPath: outputPath)
    
    do {
        let outputUrl = URL(fileURLWithPath: outputPath)
        var resourceValue: AnyObject?
        try (outputUrl as NSURL).getResourceValue(&resourceValue, forKey: URLResourceKey.isDirectoryKey)
        
        let writeUrl: URL = outputUrl.appendingPathComponent(ResourceKitConfig.outputFileName, isDirectory: false)
        
        let projectFileURL = URL(fileURLWithPath: projectFilePath)
        guard let pbxprojectPath = URL(string: projectFileURL.absoluteString + "project.pbxproj") else {
            throw ResourceKitErrorType.xcodeProjectError(xcodeURL: projectFileURL, target: "Unknown", errorInfo: "Can't find project.pbxproj")
        }
        let projectTarget = ResourceKitConfig.Debug.projectTarget ?? Environment.TARGET_NAME.element
        let parser = try ProjectResourceParser(xcodeURL: pbxprojectPath, target: projectTarget, writeResource: ProjectResource.shared, config: config)
        let paths = ProjectResource.shared.paths
        
        paths
            .filter { $0.pathExtension == "storyboard" }
            .forEach { try? StoryboardParserImpl(url: $0, writeResource: ProjectResource.shared, config: config).parse() }
        
        paths
            .filter { $0.pathExtension == "xib" }
            .forEach { try? XibPerserImpl(url: $0, writeResource: ProjectResource.shared).parse() }
        
        let importsContent = ImportOutputImpl(writeUrl: writeUrl, config: config).declaration
        
        let viewControllerContent = try ProjectResource
            .shared
            .viewControllers
            .map { (viewController) in
                try ViewControllerTranslator(config: config, viewControllers: ProjectResource.shared.viewControllers).translate(for: viewController).declaration
            }
            .joined()
        
        let tableViewCellContent: String
        let collectionViewCellContent: String
        
        if config.reusable.identifier {
            tableViewCellContent = try ProjectResource.shared.tableViewCells
                .flatMap { try ReusableTranslator().translate(for: $0).declaration + Const.newLine }
                .joined(separator: Const.newLine)
                .appendNewLineIfNotEmpty()
            
            collectionViewCellContent = try ProjectResource.shared.collectionViewCells
                .flatMap { try ReusableTranslator().translate(for: $0).declaration + Const.newLine }
                .joined(separator: Const.newLine)
                .appendNewLineIfNotEmpty()
            
        } else {
            tableViewCellContent = ""
            collectionViewCellContent = ""
        }
        
        let xibContent: String
        if config.nib.xib {
            xibContent = try ProjectResource.shared.xibs
                .flatMap { try XibTranslator().translate(for: $0).declaration }
                .joined(separator: Const.newLine)
                .appendNewLineIfNotEmpty()
        } else {
            xibContent = ""
        }
        
        let imageContent = try ImageTranslator(config: config).translate(
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
            Const.Header
                + importsContent + Const.newLine
                + ExtensionsOutputImpl().reusableProtocolContent + Const.newLine + Const.newLine
                + ExtensionsOutputImpl().xibProtocolContent + Const.newLine + Const.newLine
                + ExtensionsOutputImpl().tableViewExtensionContent + Const.newLine + Const.newLine
                + ExtensionsOutputImpl().collectionViewExtensionContent + Const.newLine + Const.newLine
                + viewControllerContent + Const.newLine
                + tableViewCellContent + Const.newLine
                + collectionViewCellContent + Const.newLine
                + xibContent + Const.newLine
                + imageContent + Const.newLine
                + stringContent + Const.newLine
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
        
        print("missing write content")
        exit(3)
    }
}


main.run()
