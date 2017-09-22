//
//  XibParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

final class XibPerser: NSObject, Parsable {
    fileprivate var _name: String = ""
    fileprivate var isOnce: Bool = false
    fileprivate let ignoreCase = [
        "UIResponder"
    ]
    
    init(url: URL) throws {
        super.init()
        
        guard url.pathExtension == "xib" else {
            throw ResourceKitErrorType.spcifiedPathError(path: url.absoluteString, errorInfo: ResourceKitErrorType.createErrorInfo())
        }
    
    
        _name = url.deletingPathExtension().lastPathComponent
        // Don't create ipad resources
        if _name.contains("~") {
            return
        }
        
        ProjectResource
            .shared
            .xibIdentifiers
            .append(_name)
        
        guard let parser = XMLParser(contentsOf: url) else {
            throw ResourceKitErrorType.spcifiedPathError(path: url.absoluteString, errorInfo: ResourceKitErrorType.createErrorInfo())
        }
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        generateXibs(attributeDict, elementName: elementName)
    }
    
    fileprivate func generateXibs(_ attributes: [String: String], elementName: String) {
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
            .shared
            .appendXibForView(
                XibForView(
                    nibName: _name,
                    className: className,
                    isFilesOwner: hasFilesOwner
                )
        )
    }
}

