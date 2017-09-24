//
//  StoryboardParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol StoryboardParser: Parsable {
    
}

final class StoryboardParserImpl: NSObject, StoryboardParser {
    let url: URL
    let resource: AppendableForStoryboard
    
    fileprivate var name: String = ""
    fileprivate var initialViewControllerIdentifier: String?
    fileprivate var currentViewControllerInfoForSegue: ViewControllerInfoOfStoryboard?
    
    init(url: URL, writeResource resource: AppendableForStoryboard) throws {
        self.url = url
        self.resource = resource
        super.init()
    }
    
    func parse() throws {
        guard url.pathExtension == "storyboard" else {
            throw ResourceKitErrorType.spcifiedPathError(path: url.absoluteString, errorInfo: ResourceKitErrorType.createErrorInfo())
        }
        
        name = url.deletingPathExtension().lastPathComponent
        // Don't create ipad resources
        if name.contains("~") { 
            return
        }
        
        guard let parser = XMLParser(contentsOf: url) else {
            throw ResourceKitErrorType.spcifiedPathError(path: url.absoluteString, errorInfo: ResourceKitErrorType.createErrorInfo())
        }
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "document" {
            initialViewControllerIdentifier = attributeDict["initialViewController"]
            return
        }
        
        if ResourceType.isViewControllerStandardType(elementName) {
            generateViewControllerResourceType(attributeDict, elementName: elementName)
        }
        
        if ResourceType.isSegue(elementName) {
            extranctionForSegue(attributeDict, elementName: elementName)
        }
        
        if ResourceType.isTableViewCell(elementName) {
            generateTableViewCells(attributeDict, elementName: elementName)
        }
        
        if ResourceType.isCollectionViewCell(elementName) {
            generateCollectionViewCells(attributeDict, elementName: elementName)
        }
    }
    
    fileprivate func generateViewControllerResourceType(_ attributes: [String: String], elementName: String) {
        guard let viewControllerId = attributes["id"] else {
            return
        }
        
        if !config.viewController.instantiateStoryboardAny {
            return
        }
        
        guard let storyboardIdentifier = attributes["storyboardIdentifier"],
            let viewControllerName = try? ResourceType(viewController: attributes["customClass"] ?? elementName).name else {
                currentViewControllerInfoForSegue = nil
                return
        }
        
        let currentViewControllerInfo = ViewControllerInfoOfStoryboard (
            viewControllerId: viewControllerId,
            storyboardName: name,
            initialViewControllerId: initialViewControllerIdentifier,
            storyboardIdentifier: storyboardIdentifier
        )
        
        resource
            .appendViewControllerInfoReference(
                viewControllerName,
                viewControllerInfo: currentViewControllerInfo
            )
        
        // store for extranctionForSegue(_:, elementName:)
        currentViewControllerInfoForSegue = currentViewControllerInfo
    }
    
    fileprivate func extranctionForSegue(_ attributes: [String: String], elementName: String) {
        guard let segueIdentifier = attributes["identifier"] else {
            return
        }
        
        if !config.needGenerateSegue {
            return
        }
        
        currentViewControllerInfoForSegue?.segues.append(segueIdentifier)
    }
    
    fileprivate func generateTableViewCells(_ attributes: [String: String], elementName: String) {
        guard let reusableIdentifier = attributes["reuseIdentifier"] else {
            return
        }
        
        if !config.reusable.identifier {
            return
        }
        
        guard let className = try? ResourceType(reusable: attributes["customClass"] ?? elementName).name else {
            return
        }
        
        resource
            .appendTableViewCell(
                className,
                reusableIdentifier: reusableIdentifier
        )
    }
    
    fileprivate func generateCollectionViewCells(_ attributes: [String: String], elementName: String) {
        guard let reusableIdentifier = attributes["reuseIdentifier"] else {
            return
        }
        
        if !config.reusable.identifier {
            return
        }
        
        guard let className = try? ResourceType(reusable: attributes["customClass"] ?? elementName).name else {
            return
        }
        
        resource
            .appendCollectionViewCell(
                className,
                reusableIdentifier: reusableIdentifier
        )
    }
}
