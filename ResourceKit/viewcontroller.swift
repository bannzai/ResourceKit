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
    
    func needOverride(storyboard: ViewControllerInfoOfStoryboard) -> Bool {
        
        // Check has superClass
        guard let superClass = ProjectResource.sharedInstance.viewControllers
            .filter ({ $0.className == superClassName })
            .first
            else {
                return false
        }
        
        // For initialViewController()
        let storyboardsForIsNotInitial = superClass.storyboardInfos.filter({ !$0.isInitial })
        let superClassHasInitial = storyboardsForIsNotInitial.count != superClass.storyboardInfos.count
        let needOverrideForInitial = superClassHasInitial && storyboard.isInitial
        if needOverrideForInitial {
            return true
        }
        
        // For not initialViewController()
        if storyboard.storyboardIdentifier.isEmpty {
            return false
        }
        
        guard let superClassStoryboardIdentifier = storyboardsForIsNotInitial
            .filter({ $0.storyboardName == storyboard.storyboardName })
            .flatMap ({ $0.storyboardIdentifier })
            .first
            else {
            return false
        }
        
        return superClassStoryboardIdentifier == storyboard.storyboardIdentifier
    }
    
    func classFunctionHead(storyboard: ViewControllerInfoOfStoryboard) -> String {
        return needOverride(storyboard) ? "class override" : "class"
    }

    func instanceFunctionHead(storyboard: ViewControllerInfoOfStoryboard) -> String {
        return needOverride(storyboard) ? "override" : "internal"
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
                    value: $0
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
            head: instanceFunctionHead(storyboard),
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
                head: classFunctionHead(storyboard),
                name: "instanceFrom\(storyboard.storyboardName + storyboard.storyboardIdentifier)",
                arguments: [],
                returnType: name,
                body: Body ([
                    "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ", //TODO: Bundle
                    "let viewController = storyboard.instantiateViewControllerWithIdentifier(\"\(storyboard.storyboardIdentifier)\") as! \(name)",
                    "return viewController",
                    ])
            )
        }
        
        return Function (
            head: classFunctionHead(storyboard),
            name: "instanceFrom\(storyboard.storyboardName)",
            arguments: [],
            returnType: name,
            body: Body([
                "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ", //TODO: Bundle
                "let viewController = storyboard.instantiateViewControllerWithIdentifier(\"\(storyboard.storyboardIdentifier)\") as! \(name)",
                "return viewController",
            ])
        )
    }
    
    private func fromStoryboardForInitial(storyboard: ViewControllerInfoOfStoryboard) -> Function {
        if storyboardInfos.filter ({ $0.isInitial }).count > 1 {
            return Function (
                head: classFunctionHead(storyboard),
                name: "initialFrom\(storyboard.storyboardName)",
                arguments: [],
                returnType: name,
                body: Body([
                    "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ", //TODO: Bundle
                    "let viewController = storyboard.instantiateInitialViewController() as! \(name)",
                    "return viewController",
                    ])
            )
        }
        return Function (
            head: classFunctionHead(storyboard),
            name: "initialViewController",
            arguments: [],
            returnType: name,
            body: Body([
                "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ", //TODO: Bundle
                "let viewController = storyboard.instantiateInitialViewController() as! \(name)",
                "return viewController",
            ])
        )
    }
}
