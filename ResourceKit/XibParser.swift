//
//  XibParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

final class XibPerser: NSObject, Parsable {
    private var _name: String = ""
    private var isOnce: Bool = false
    private let ignoreCase = [
        "UIResponder"
    ]
    
    init(url: NSURL) {
        super.init()
        
        guard let ex = url.pathExtension where ex == "xib" else {
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
        
        ProjectResource
            .sharedInstance
            .xibIdentifiers
            .append(_name)
        
        let parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        generateXibs(attributeDict, elementName: elementName)
    }
    
    private func generateXibs(attributes: [String: String], elementName: String) {
        if isOnce {
            return
        }
        
        guard let className = attributes["customClass"] else {
            return
        }
        if ignoreCase.contains(className) {
            return
        }
        
        let hasFilesOwner = attributes.flatMap ({ $1 }).contains("IBFilesOwner")
        if hasFilesOwner {
            return
        }
        
        isOnce = true
        ProjectResource
            .sharedInstance
            .appendXibForView(
            XibForView(
                name: _name,
                className: className,
                isFilesOwner: hasFilesOwner
            )
        )
    }
}

