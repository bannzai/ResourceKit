//
//  resource.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/04/15.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation


enum ResourceType: Equatable {
    case Standard(String)
    case Custom(String)
    
    static func isSegue(elementName: String) -> Bool {
        return elementName == "segue"
    }
    
    static func isTableViewCell(elementName: String) -> Bool {
        if let reusable = ReusableResource(name: elementName)
        where reusable == .UITableViewCell {
            return true
        }
        
        return false
    }
    
    static func isCollectionViewCell(elementName: String) -> Bool {
        if let reusable = ReusableResource(name: elementName)
        where reusable == .UICollectionViewCell {
            return true
        }
        
        return false
    }
    
    static func isReusableStandardType(elementName: String) -> Bool {
        return isTableViewCell(elementName) || isCollectionViewCell(elementName)
    }
    
    static func isViewControllerStandardType(elementName: String) -> Bool {
        if let _ = ViewControllerResource(name: elementName) {
            return true
        }
        
        return false
    }
    
    init(reusable: String) {
        if ResourceType.isReusableStandardType(reusable) {
            self = Standard(ReusableResource(name: reusable)!.rawValue)
            return
        }
        
        self = Custom(reusable)
    }
    
    init(viewController: String) {
        if ResourceType.isViewControllerStandardType(viewController) {
            self = Standard(ViewControllerResource(name: viewController)!.rawValue)
            return
        }
        
        self = Custom(viewController)
    }
    
    var name: String {
        switch self {
        case .Standard(let standard):
            return standard
        case .Custom(let custom):
            return custom
        }
    }
}

func ==(lhs: ResourceType, rhs: ResourceType) -> Bool {
    return lhs.name == rhs.name
}