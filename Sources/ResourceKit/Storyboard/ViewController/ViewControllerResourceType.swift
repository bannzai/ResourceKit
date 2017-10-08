//
//  ViewControllerResourceType.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

enum ViewControllerResourceType: String {
    case UIViewController
    case UITabBarController
    case UIPageViewController
    case UITableViewController
    case UISplitViewController
    case UINavigationController
    case UICollectionViewController
    
    init?(name: String) {
        switch name {
        case "viewController":
            self = .UIViewController
        case "tabBarController":
            self = .UITabBarController
        case "pageViewController":
            self = .UIPageViewController
        case "tableViewController":
            self = .UITableViewController
        case "splitViewController":
            self = .UISplitViewController
        case "navigationController":
            self = .UINavigationController
        case "collectionViewController":
            self = .UICollectionViewController
        default: return nil
        }
    }
    
    static func standards() -> [ViewControllerResourceType] {
        return [
            .UIViewController,
            .UITabBarController,
            .UIPageViewController,
            .UITableViewController,
            .UISplitViewController,
            .UINavigationController,
            .UICollectionViewController
        ]
    }
}
