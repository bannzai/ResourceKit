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
    
    fileprivate var _seguesForGenerateStruct: [String] = []
    
    fileprivate lazy var hasSupeClass: Bool = {
        return self.superClass != nil
    }()
    
    fileprivate lazy var superClass: ViewController? =
        ProjectResource.sharedInstance.viewControllers
        .filter ({ $0.className == self.superClassName })
        .first
    
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
    
    init(className: String, superClassName: String = "") throws {
        self.className = try ResourceType(viewController: className)
        self.superClassName = try ResourceType(viewController: superClassName)
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
        let begin = "\(accessControl) extension \(name) {"
        let fromStoryboardFunctions = storyboardInfos.flatMap {
            self.generateFromStoryboardFunctions(from: $0)
        }.joined(separator: newLine)
        let segueStruct = generateForSegueStruct()
        let body = fromStoryboardFunctions + newLine + segueStruct
        let end = "}" +  newLine
        
        return begin + body + end
        
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
        
        let begin = "\(accessControl) struct Segue {"
        let body = _seguesForGenerateStruct.flatMap {
            "\(accessControl) static let \($0.lowerFirst): String = \($0)"
            }.joined(separator: newLine)
        let end = "}"
        return begin + body + end
    }
    
    fileprivate func generateFromStoryboardFunctions(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        if !config.viewController.instantiateStoryboardAny &&
            !config.needGenerateSegue {
            return ""
        }
        
        if !config.viewController.instantiateStoryboardAny {
            return generatePerformSegues(from: storyboard)
        }
        
        if !config.needGenerateSegue {
            return generateFromStoryboard(from: storyboard)
        }
        
        return generateFromStoryboard(from: storyboard) + generatePerformSegues(from: storyboard)
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
        let overrideOrEmpty = makeOverrideIfNeededForPerformSegue(from: storyboard) ?? ""
        if config.segue.addition {
            return [
                "\(overrideOrEmpty) \(accessControl) func performSegue\(segueIdentifier)(closure: ((UIStoryboardSegue) -> Void)? = nil) {",
                "   performSegue(\"\(segueIdentifier)\", closure: closure)",
                "}",
            ].joined(separator: newLine)
        }
        return [
            "\(overrideOrEmpty) \(accessControl) func performSegue\(segueIdentifier)(sender: AnyObject? = nil) {",
            "   performSegue(withIdentifier: \"\(segueIdentifier)\", sender: sender)",
            "}",
            ].joined(separator: newLine)
    }
    
    fileprivate func generateFromStoryboard(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        return storyboard.isInitial ? fromStoryboardForInitial(from: storyboard) : fromStoryboard(from: storyboard)
    }
    
    fileprivate func fromStoryboard(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        if storyboard.storyboardIdentifier.isEmpty {
            return ""
        }
        
        let overrideOrEmpty = makeOverrideIfNeededForFromStoryboardFunction(from: storyboard) ?? ""
        let head = "\(overrideOrEmpty) \(accessControl) class func"
        if storyboardInfos.filter({ $0.storyboardName == storyboard.storyboardName }).count > 1 {
            return [
                head + "instanceFrom\(storyboard.storyboardName + storyboard.storyboardIdentifier)() {",
                "   let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                "   let viewController = storyboard.instantiateViewController(withIdentifier: \"\(storyboard.storyboardIdentifier)\") as! \(name)",
                "   return viewController",
                "}"
            ].joined(separator: newLine)
        }
        
        return [
            head + "instanceFrom\(storyboard.storyboardName)() {",
            "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
            "let viewController = storyboard.instantiateViewController(withIdentifier: \"\(storyboard.storyboardIdentifier)\") as! \(name)",
            "return viewController",
            "}",
        ].joined(separator: newLine)
    }
    
    fileprivate func fromStoryboardForInitial(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        let overrideOrEmpty = makeOverrideIfNeededForFromStoryboardFunction(from: storyboard) ?? ""
        let head = "\(overrideOrEmpty) \(accessControl) class func"
        
        if storyboardInfos.filter ({ $0.isInitial }).count > 1 {
            return [
                head + "initialFrom\(storyboard.storyboardName)() {",
                "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                "let viewController = storyboard.instantiateInitialViewController() as! \(name)",
                "return viewController",
                "}"
                ].joined(separator: newLine)
        }
        
        return [
            head + "initialViewController() {",
            "let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ", 
            "let viewController = storyboard.instantiateInitialViewController() as! \(name)",
            "return viewController",
            "}"
            ].joined(separator: newLine)
    }
}
