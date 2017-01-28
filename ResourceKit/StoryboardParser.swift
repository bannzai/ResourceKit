//
//  StoryboardParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

final class StoryboardParser: NSObject, Parsable {
    fileprivate var _name: String = ""
    fileprivate var _initialViewControllerIdentifier: String?
    fileprivate var _viewControllerInfos: [ViewControllerInfoOfStoryboard] = []
    fileprivate var _currentViewControllerInfo: ViewControllerInfoOfStoryboard?
    
    init(url: URL) throws {
        super.init()
        
        guard url.pathExtension == "storyboard" else {
            throw ResourceKitErrorType.spcifiedPathError(path: url.absoluteString, errorInfo: ResourceKitErrorType.createErrorInfo())
        }
        
        _name = url.deletingPathExtension().lastPathComponent
        // Don't create ipad resources
        if _name.contains("~") { 
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
            _initialViewControllerIdentifier = attributeDict["initialViewController"]
            return
        }
        
        if ResourceType.isViewControllerStandardType(elementName) {
            generateViewControllerResource(attributeDict, elementName: elementName)
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
    
    fileprivate func extranctionForSegue(_ attributes: [String: String], elementName: String) {
        guard let segueIdentifier = attributes["identifier"] else {
            return
        }
        
        if !config.needGenerateSegue {
            return
        }
        
        _currentViewControllerInfo?.segues.append(segueIdentifier)
    }
    
    fileprivate func generateViewControllerResource(_ attributes: [String: String], elementName: String) {
        guard let viewControllerId = attributes["id"] else {
            return
        }
        
        if !config.viewController.instantiateStoryboardAny {
            return
        }
        
        let storyboardIdentifier = attributes["storyboardIdentifier"] ?? ""
        let viewControllerName = try? ResourceType(viewController: attributes["customClass"] ?? elementName).name
        
        let currentViewControllerInfo = ViewControllerInfoOfStoryboard (
            viewControllerId: viewControllerId,
            storyboardName: _name,
            initialViewControllerId: _initialViewControllerIdentifier,
            storyboardIdentifier: storyboardIdentifier
        )
        
        ProjectResource
            .sharedInstance
            .viewControllers
            .filter({ $0.name == viewControllerName })
            .first?
            .storyboardInfos
            .append(currentViewControllerInfo)
        
        _currentViewControllerInfo = currentViewControllerInfo
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
        
        ProjectResource
            .sharedInstance
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
        
        ProjectResource
            .sharedInstance
            .appendCollectionViewCell(
                className,
                reusableIdentifier: reusableIdentifier
        )
    }
}
