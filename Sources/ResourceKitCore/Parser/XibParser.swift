//
//  XibParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

public protocol XibParser: Parsable {
    
}

public class XibPerserImpl: NSObject, XibParser {
    let url: URL
    let resource: AppendableForXibs
    
    fileprivate var name: String = ""
    // should parse for root view
    // ResourceKit not support second xib view
    fileprivate var isOnce: Bool = false
    fileprivate let ignoreCase = [
        "UIResponder"
    ]
    
    public init(url: URL, writeResource resource: AppendableForXibs) throws {
        self.url = url
        self.resource = resource
        
        super.init()
    }
    
    public func parse() throws {
        guard url.pathExtension == "xib" else {
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
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
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
        
        resource
            .appendXib(
                Xib(
                    nibName: name,
                    className: className,
                    isFilesOwner: hasFilesOwner
                )
        )
    }
}

