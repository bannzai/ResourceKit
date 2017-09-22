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

class SwiftViewController: ViewController {
    
}

class ViewController {
    var storyboardInfos: [ViewControllerInfoOfStoryboard] = []
    let className: ResourceType
    let superClassName: ResourceType 
    
    fileprivate var _seguesForGenerateStruct: [String] = []
    
    fileprivate lazy var hasSupeClass: Bool = {
        return self.superClass != nil
    }()
    
    fileprivate lazy var superClass: ViewController? = ProjectResource
        .shared
        .viewControllers
        .filter ({ $0.className == self.superClassName })
        .first
    
    init(className: String, superClassName: String = "") throws {
        self.className = try ResourceType(viewController: className)
        self.superClassName = try ResourceType(viewController: superClassName)
    }
    
    func needOverrideForStoryboard(_ storyboard: ViewControllerInfoOfStoryboard) -> Bool {
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
    
    func needOverrideForSegue(_ storyboard: ViewControllerInfoOfStoryboard) -> Bool {
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
    
    func makeOverrideIfNeededForFromStoryboardFunction(from storyboard: ViewControllerInfoOfStoryboard) -> String? {
        return needOverrideForStoryboard(storyboard) ? "override" : nil
    }

    func makeOverrideIfNeededForPerformSegue(from storyboard: ViewControllerInfoOfStoryboard) -> String? {
        return needOverrideForSegue(storyboard) ? "override" : nil
    }
    
    var name: String {
        return className.name
    }
    
}

extension ViewController: Declaration {
    var declaration: String {
        return generateDeclarationIfStoryboardInfoExists()
    }
    
    fileprivate func generateDeclarationIfStoryboardInfoExists() -> String {
        if storyboardInfos.isEmpty {
            return ""
        }
        
        return generateDeclaration()
    }
    
    fileprivate func generateDeclaration() -> String {
        defer {
            removeTemporary()
        }
        let begin = "\(accessControl) extension \(name) {" + newLine
        let fromStoryboardFunctions = storyboardInfos.flatMap {
            self.generateFromStoryboardFunctions(from: $0)
        }.joined(separator: newLine)
        let segueStruct = generateForSegueStruct()
        let body = fromStoryboardFunctions + newLine + segueStruct
        let end = "}" +  newLine
        
        return [begin, body, end].joined(separator: newLine)
        
    }
    
    fileprivate func removeTemporary() {
        _seguesForGenerateStruct.removeAll()
    }
    
    fileprivate func generateForSegueStruct() -> String {
        if !config.segue.standard {
            return ""
        }
        if _seguesForGenerateStruct.isEmpty {
            return ""
        }
        
        let begin = "\(tab1)\(accessControl) struct Segue {" 
        let body = _seguesForGenerateStruct.flatMap {
            "\(tab2)\(accessControl) static let \($0.lowerFirst): String = \"\($0)\""
            }.joined(separator: newLine)
        let end = "\(tab1)}"
        return [begin, body, end].joined(separator: newLine)
    }
    
    fileprivate func generateFromStoryboardFunctions(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        if !config.viewController.instantiateStoryboardAny &&
            !config.needGenerateSegue {
            return ""
        }
        
        if !config.viewController.instantiateStoryboardAny {
            return generatePerformSegues(from: storyboard) + newLine
        }
        
        if !config.needGenerateSegue {
            return generateFromStoryboard(from: storyboard) + newLine
        }
        
        return generateFromStoryboard(from: storyboard) + newLine + generatePerformSegues(from: storyboard) + newLine
    }
    
    fileprivate func generatePerformSegues(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        if !config.needGenerateSegue {
            return ""
        }
        
        return storyboard
            .segues
            .flatMap {
                generatePerformSegueAndTemporarySave(storyboard, segueIdentifier: $0)
            }
            .joined(separator: newLine)
    }
    
    fileprivate func generatePerformSegueAndTemporarySave(_ storyboard: ViewControllerInfoOfStoryboard, segueIdentifier: String) -> String {
       _seguesForGenerateStruct.append(segueIdentifier)
        return generatePerformSegue(from: storyboard, and: segueIdentifier)
    }
    
    fileprivate func generatePerformSegue(from storyboard: ViewControllerInfoOfStoryboard, and segueIdentifier: String) -> String {
        let overrideOrNil = makeOverrideIfNeededForPerformSegue(from: storyboard)
        let overrideOrEmpty = overrideOrNil == nil ? "" : overrideOrNil! + " "
        let head = "\(tab1)\(overrideOrEmpty)"
        if config.segue.addition {
            return [
                "\(head) \(accessControl) func performSegue\(segueIdentifier)(closure: ((UIStoryboardSegue) -> Void)? = nil) {",
                "\(tab2)performSegue(\"\(segueIdentifier)\", closure: closure)",
                "\(tab1)}",
            ].joined(separator: newLine)
        }
        return [
            "\(head) \(accessControl) func performSegue\(segueIdentifier)(sender: AnyObject? = nil) {",
            "\(tab2)performSegue(withIdentifier: \"\(segueIdentifier)\", sender: sender)",
            "\(tab1)}",
            ].joined(separator: newLine)
    }
    
    fileprivate func generateFromStoryboard(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        return storyboard.isInitial ? fromStoryboardForInitial(from: storyboard) : fromStoryboard(from: storyboard) 
    }
    
    fileprivate func fromStoryboard(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        if storyboard.storyboardIdentifier.isEmpty {
            return ""
        }
        
        let overrideOrNil = makeOverrideIfNeededForFromStoryboardFunction(from: storyboard)
        let overrideOrEmpty = overrideOrNil == nil ? "" : overrideOrNil! + " "
        let head = "\(tab1)\(overrideOrEmpty)\(accessControl) class func "
        if storyboardInfos.filter({ $0.storyboardName == storyboard.storyboardName }).count > 1 {
            return [
                head + "instanceFrom\(storyboard.storyboardName + storyboard.storyboardIdentifier)() -> \(className.name) {",
                "\(tab2)let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                "\(tab2)let viewController = storyboard.instantiateViewController(withIdentifier: \"\(storyboard.storyboardIdentifier)\") as! \(name)",
                "\(tab2)return viewController",
                "\(tab1)}"
            ].joined(separator: newLine)
        }
        
        return [
            head + "instanceFrom\(storyboard.storyboardName)() -> \(className.name) {",
            "\(tab2)let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
            "\(tab2)let viewController = storyboard.instantiateViewController(withIdentifier: \"\(storyboard.storyboardIdentifier)\") as! \(name)",
            "\(tab2)return viewController",
            "\(tab1)}",
        ].joined(separator: newLine)
    }
    
    fileprivate func fromStoryboardForInitial(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        let overrideOrNil = makeOverrideIfNeededForFromStoryboardFunction(from: storyboard)
        let overrideOrEmpty = overrideOrNil == nil ? "" : overrideOrNil! + " "
        let head = "\(tab1)\(overrideOrEmpty)\(accessControl) class func "
        
        if storyboardInfos.filter ({ $0.isInitial }).count > 1 {
            return [
                head + "initialFrom\(storyboard.storyboardName)() -> \(className.name) {",
                "\(tab2)let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                "\(tab2)let viewController = storyboard.instantiateInitialViewController() as! \(name)",
                "\(tab2)return viewController",
                "\(tab1)}"
                ].joined(separator: newLine)
        }
        
        return [
            head + "initialViewController() -> \(className.name) {",
            "\(tab2)let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ", 
            "\(tab2)let viewController = storyboard.instantiateInitialViewController() as! \(name)",
            "\(tab2)return viewController",
            "\(tab1)}"
            ].joined(separator: newLine)
    }
}
