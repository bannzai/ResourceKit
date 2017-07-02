//
//  Resource.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/04/15.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation


enum ResourceType: Equatable {
    case standard(String)
    case custom(String)
    
    static func isSegue(_ elementName: String) -> Bool {
        return elementName == "segue"
    }
    
    static func isTableViewCell(_ elementName: String) -> Bool {
        if let reusable = ReusableResourceType(name: elementName)
        , reusable == .UITableViewCell {
            return true
        }
        
        return false
    }
    
    static func isCollectionViewCell(_ elementName: String) -> Bool {
        if let reusable = ReusableResourceType(name: elementName)
        , reusable == .UICollectionViewCell {
            return true
        }
        
        return false
    }
    
    static func isReusableStandardType(_ elementName: String) -> Bool {
        return isTableViewCell(elementName) || isCollectionViewCell(elementName)
    }
    
    static func isViewControllerStandardType(_ elementName: String) -> Bool {
        if let _ = ViewControllerResource(name: elementName) {
            return true
        }
        
        return false
    }
    
    init(reusable: String) throws {
        if ResourceType.isReusableStandardType(reusable) {
            guard let resource = ReusableResourceType(name: reusable) else {
                throw ResourceKitErrorType.resourceParseError(name: reusable, errorInfo: ResourceKitErrorType.createErrorInfo())
            }
            self = .standard(resource.rawValue)
            return
        }
        
        self = .custom(reusable)
    }
    
    init(viewController: String) throws {
        if ResourceType.isViewControllerStandardType(viewController) {
            guard let resource = ViewControllerResource(name: viewController) else {
                throw ResourceKitErrorType.resourceParseError(name: viewController, errorInfo: ResourceKitErrorType.createErrorInfo())
            }
            self = .standard(resource.rawValue)
            return
        }
        
        self = .custom(viewController)
    }
    
    var name: String {
        switch self {
        case .standard(let standard):
            return standard
        case .custom(let custom):
            return custom
        }
    }
}

func ==(lhs: ResourceType, rhs: ResourceType) -> Bool {
    return lhs.name == rhs.name
}
