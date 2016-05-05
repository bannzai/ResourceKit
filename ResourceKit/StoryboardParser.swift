//
//  StoryboardParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

final class StoryboardParser: NSObject, Parsable {
    private var _name: String = ""
    private var _initialViewControllerIdentifier: String?
    private var _viewControllerInfos: [ViewControllerInfoOfStoryboard] = []
    private var _currentViewControllerInfo: ViewControllerInfoOfStoryboard?
    
    init(url: NSURL) {
        super.init()
        
        guard let ex = url.pathExtension where ex == "storyboard" else {
            fatalError("\(#file) + \(#function) + \(#line)")
        }
        guard let name = url.URLByDeletingPathExtension?.lastPathComponent else {
            fatalError("\(#file) + \(#function) + \(#line)")
        }
        
        _name = name
        // Don't create ipad resources
        if _name.containsString("~") { 
            return
        }
        
        let parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
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
    
    private func extranctionForSegue(attributes: [String: String], elementName: String) {
        guard let segueIdentifier = attributes["identifier"] else {
            return
        }
        
        if !config.segue.standard {
            return
        }
        
        _currentViewControllerInfo?.segues.append(segueIdentifier)
    }
    
    private func generateViewControllerResource(attributes: [String: String], elementName: String) {
        guard let viewControllerId = attributes["id"] else {
            return
        }
        
        if !config.viewController.instantiateStoryboard {
            return
        }
        
        let storyboardIdentifier = attributes["storyboardIdentifier"] ?? ""
        let viewControllerName = ResourceType(viewController: attributes["customClass"] ?? elementName).name
        
        _currentViewControllerInfo = ViewControllerInfoOfStoryboard (
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
            .append(_currentViewControllerInfo!)
    }
    
    private func generateTableViewCells(attributes: [String: String], elementName: String) {
        guard let reusableIdentifier = attributes["reuseIdentifier"] else {
            return
        }
        
        if !config.reusable.identifier {
            return
        }
        
        let className = ResourceType(reusable: attributes["customClass"] ?? elementName).name
        ProjectResource
            .sharedInstance
            .appendTableViewCell(
                className,
                reusableIdentifier: reusableIdentifier
        )
    }
    
    private func generateCollectionViewCells(attributes: [String: String], elementName: String) {
        guard let reusableIdentifier = attributes["reuseIdentifier"] else {
            return
        }
        
        if !config.reusable.identifier {
            return
        }
        
        
        let className = ResourceType(reusable: attributes["customClass"] ?? elementName).name
        ProjectResource
            .sharedInstance
            .appendCollectionViewCell(
                className,
                reusableIdentifier: reusableIdentifier
        )
    }
}