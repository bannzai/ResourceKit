//
//  viewcontroller.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/04/06.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

enum ViewControllerResource: String {
    case UIViewController
    case UITabBarController
    case UIPageViewController
    case UITableViewController
    case UISplitViewController
    case UINavigationController
    case UICollectionViewController
    
    init?(name: String) {
        switch name {
        case "viewController":  self = .UIViewController
        case "tabBarController": self = .UITabBarController
        case "pageViewController": self = .UIPageViewController
        case "tableViewController": self = .UITableViewController
        case "splitViewController": self = .UISplitViewController
        case "navigationController": self = .UINavigationController
        case "collectionViewController": self = .UICollectionViewController
        default: return nil
        }
    }
    
    static func standards() -> [ViewControllerResource] {
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

class ViewControllerInfoOfStoryboard {
    let viewControllerId: String
    let storyboardName: String
    let initialViewControllerId: String?
    let storyboardIdentifier: String
    
    var segues: [String] = []
    
    init(viewControllerId: String,
         storyboardName: String,
         initialViewControllerId: String?,
         storyboardIdentifier: String) {
        self.viewControllerId = viewControllerId
        self.storyboardName = storyboardName
        self.initialViewControllerId = initialViewControllerId
        self.storyboardIdentifier = storyboardIdentifier
    }
    
    var isInitial: Bool {
        return viewControllerId == initialViewControllerId
    }
}

class ViewController {
    var storyboardInfos: [ViewControllerInfoOfStoryboard] = []
    let className: ResourceType
    let superClassName: ResourceType
    
    var _seguesForGenerateStruct: [String] = []
    
    private lazy var hasSupeClass: Bool = {
        return self.superClass != nil
    }()
    private lazy var superClass: ViewController? =
        ProjectResource.sharedInstance.viewControllers
        .filter ({ $0.className == self.superClassName })
        .first
    
    func needOverrideForStoryboard(storyboard: ViewControllerInfoOfStoryboard) -> Bool {
        if !hasSupeClass {
            return false
        }
        
        guard let superClass = superClass else {
            return false
        }
        
        // For initialViewController()
        let hasInitialOfSuperClass = superClass.storyboardInfos.filter({ $0.isInitial }).count > 0
        let needOverrideForInitial = hasInitialOfSuperClass && storyboard.isInitial
        if needOverrideForInitial {
            return true
        }
        
        if storyboard.storyboardIdentifier.isEmpty {
            return false
        }
        
        // For not initialViewController()
        let storyboardsForIsNotInitial = superClass.storyboardInfos.filter({ !$0.isInitial })
        return storyboardsForIsNotInitial.filter({ $0.storyboardName == storyboard.storyboardName }).count > 1
    }
    
    func needOverrideForSegue(storyboard: ViewControllerInfoOfStoryboard) -> Bool {
        if !hasSupeClass {
            return false
        }
        
        guard let superClass = superClass else {
            return false
        }
        
        let superClassSegues = superClass.storyboardInfos.flatMap { $0.segues }
        let segues = storyboardInfos.flatMap { $0.segues }
        
        return superClassSegues.contains { superClassSegue in
            segues.contains { segue in
                segue == superClassSegue
            }
        }
    }

    
    func classFunctionHeadForViewControllerInstance(storyboard: ViewControllerInfoOfStoryboard) -> String {
        return needOverrideForStoryboard(storyboard) ? "class override" : "class"
    }

    func instanceFunctionHeadForSegue(storyboard: ViewControllerInfoOfStoryboard) -> String {
        return needOverrideForSegue(storyboard) ? "override" : "internal"
    }
    
    var name: String {
        return className.name
    }
    
    init(className: String, superClassName: String = "") {
        self.className = ResourceType(viewController: className)
        self.superClassName = ResourceType(viewController: superClassName)
    }
    
}

extension ViewController {
    func generateExtension() -> Extension {
        defer {
            removeTemporary()
        }
        return Extension (
            type: name,
            functions: storyboardInfos.flatMap { self.generateFunctions($0) },
            structs: structs()
        )
    }
    
    func removeTemporary() {
        _seguesForGenerateStruct.removeAll()
    }
    
    func generateExtensionIfNeeded() -> Extension? {
        if storyboardInfos.isEmpty {
            return nil
        }
        return generateExtension()
    }
    
    private func structs() -> [Struct] {
        if _seguesForGenerateStruct.isEmpty {
            return []
        }
        return [segueStructs(_seguesForGenerateStruct)]
    }
    
    private func segueStructs(segueIdentifiers: [String]) -> Struct {
        return Struct (
            name: "Segue",
            lets: segueIdentifiers.flatMap {
                Let (
                    isStatic: true,
                    name: $0.lowerFirst,
                    type: "String",
                    value: $0,
                    isConvertStringValue: true
                )
            }
        )
    }
    
    private func generateFunctions(storyboard: ViewControllerInfoOfStoryboard) -> [Function] {
        return [generateFromStoryboard(storyboard)] + performSegues(storyboard)
    }
    
    private func performSegues(storyboard: ViewControllerInfoOfStoryboard) -> [Function] {
        return storyboard.segues.flatMap {
            performSegueAndTemporarySave(storyboard, segueIdentifier: $0)
        }
    }
    
    private func performSegueAndTemporarySave(storyboard: ViewControllerInfoOfStoryboard, segueIdentifier: String) -> Function {
       _seguesForGenerateStruct.append(segueIdentifier)
        return performSegue(storyboard, segueIdentifier: segueIdentifier)
    }
    
    private func performSegue(storyboard: ViewControllerInfoOfStoryboard, segueIdentifier: String) -> Function {
        return Function (
            head: instanceFunctionHeadForSegue(storyboard),
            name: "perFormSegue\(segueIdentifier)",
            arguments: [Argument(name: "sender", type: "AnyObject?", defaultValue: "nil")],
            returnType: "Void",
            body: Body(
                "performSegueWithIdentifier(\"\(segueIdentifier)\", sender: sender)"
                )
        )
    }
    
    private func generateFromStoryboard(storyboard: ViewControllerInfoOfStoryboard) -> Function {
        return storyboard.isInitial ? fromStoryboardForInitial(storyboard) : fromStoryboard(storyboard)
    }
    
    private func fromStoryboard(storyboard: ViewControllerInfoOfStoryboard) -> Function {
        if storyboard.storyboardIdentifier.isEmpty {
            return Function.dummyFunction()
        }
        
        if storyboardInfos.filter({ $0.storyboardName == storyboard.storyboardName }).count > 1 {
            return Function (
                head: classFunctionHeadForViewControllerInstance(storyboard),
                name: "instanceFrom\(storyboard.storyboardName + storyboard.storyboardIdentifier)",
                arguments: [],
                returnType: name,
                body: Body ([
                    "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                    "let viewController = storyboard.instantiateViewControllerWithIdentifier(\"\(storyboard.storyboardIdentifier)\") as! \(name)",
                    "return viewController",
                    ])
            )
        }
        
        return Function (
            head: classFunctionHeadForViewControllerInstance(storyboard),
            name: "instanceFrom\(storyboard.storyboardName)",
            arguments: [],
            returnType: name,
            body: Body([
                "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                "let viewController = storyboard.instantiateViewControllerWithIdentifier(\"\(storyboard.storyboardIdentifier)\") as! \(name)",
                "return viewController",
            ])
        )
    }
    
    private func fromStoryboardForInitial(storyboard: ViewControllerInfoOfStoryboard) -> Function {
        if storyboardInfos.filter ({ $0.isInitial }).count > 1 {
            return Function (
                head: classFunctionHeadForViewControllerInstance(storyboard),
                name: "initialFrom\(storyboard.storyboardName)",
                arguments: [],
                returnType: name,
                body: Body([
                    "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                    "let viewController = storyboard.instantiateInitialViewController() as! \(name)",
                    "return viewController",
                    ])
            )
        }
        return Function (
            head: classFunctionHeadForViewControllerInstance(storyboard),
            name: "initialViewController",
            arguments: [],
            returnType: name,
            body: Body([
                "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ", 
                "let viewController = storyboard.instantiateInitialViewController() as! \(name)",
                "return viewController",
            ])
        )
    }
}
