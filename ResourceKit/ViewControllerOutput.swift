//
//  ViewControllerOutput.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/23.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol ViewControllerOutput: Output {
    
}

struct ViewControllerOutputImpl: ViewControllerOutput {
    fileprivate var seguesForGenerateStruct: [String] = []
    
    let name: String
    let storyboardInfos: [ViewControllerInfoOfStoryboard]
    let hasSuperClass: Bool
    let superClassStoryboardInfos: [ViewControllerInfoOfStoryboard]
    fileprivate(set) var declaration: String = ""
    
    init(
        name: String,
        storyboardInfos: [ViewControllerInfoOfStoryboard],
        hasSuperClass: Bool,
        superClassStoryboardInfos: [ViewControllerInfoOfStoryboard]
        ) {
        self.name = name
        self.storyboardInfos = storyboardInfos
        self.hasSuperClass = hasSuperClass
        self.superClassStoryboardInfos = superClassStoryboardInfos
        
        self.declaration = generateDeclarationIfStoryboardInfoExists()
    }
    
}

// MARK: - Private
fileprivate extension ViewControllerOutputImpl {
    mutating func generateDeclarationIfStoryboardInfoExists() -> String {
        if storyboardInfos.isEmpty {
            return ""
        }
        
        return generateDeclaration()
    }
    
    mutating func generateDeclaration() -> String {
        defer {
            removeTemporary()
        }
        let begin = "extension \(name) {" + newLine
        let fromStoryboardFunctions = storyboardInfos.flatMap {
            self.generateFromStoryboardFunctions(from: $0)
            }.joined(separator: newLine)
        let segueStruct = generateForSegueStruct()
        let body = fromStoryboardFunctions + newLine + segueStruct
        let end = "}" +  newLine
        
        return [begin, body, end].joined(separator: newLine)
        
    }
    
    mutating func removeTemporary() {
        seguesForGenerateStruct.removeAll()
    }
    
    func generateForSegueStruct() -> String {
        if !config.segue.standard {
            return ""
        }
        if seguesForGenerateStruct.isEmpty {
            return ""
        }
        
        let begin = "\(tab1)struct Segue {" 
        let body = seguesForGenerateStruct.flatMap {
            "\(tab2)static let \($0.lowerFirst): String = \"\($0)\""
            }.joined(separator: newLine)
        let end = "\(tab1)}"
        return [begin, body, end].joined(separator: newLine)
    }
    
    mutating func generateFromStoryboardFunctions(from storyboard: ViewControllerInfoOfStoryboard) -> String {
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
    
    mutating func generatePerformSegues(from storyboard: ViewControllerInfoOfStoryboard) -> String {
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
    
    mutating func generatePerformSegueAndTemporarySave(_ storyboard: ViewControllerInfoOfStoryboard, segueIdentifier: String) -> String {
        seguesForGenerateStruct.append(segueIdentifier)
        return generatePerformSegue(from: storyboard, and: segueIdentifier)
    }
    
    func generatePerformSegue(from storyboard: ViewControllerInfoOfStoryboard, and segueIdentifier: String) -> String {
        let overrideOrNil = makeOverrideIfNeededForPerformSegue(from: storyboard)
        let overrideOrEmpty = overrideOrNil == nil ? "" : overrideOrNil! + " "
        let head = "\(tab1)\(overrideOrEmpty)"
        if config.segue.addition {
            return [
                "\(head)func performSegue\(segueIdentifier)(closure: ((UIStoryboardSegue) -> Void)? = nil) {",
                "\(tab2)performSegue(\"\(segueIdentifier)\", closure: closure)",
                "\(tab1)}",
                ].joined(separator: newLine)
        }
        return [
            "\(head)func performSegue\(segueIdentifier)(sender: AnyObject? = nil) {",
            "\(tab2)performSegue(withIdentifier: \"\(segueIdentifier)\", sender: sender)",
            "\(tab1)}",
            ].joined(separator: newLine)
    }
    
    mutating func generateFromStoryboard(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        return storyboard.isInitial ? fromStoryboardForInitial(from: storyboard) : fromStoryboard(from: storyboard)
    }
    
    mutating func fromStoryboard(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        if storyboard.storyboardIdentifier.isEmpty {
            return ""
        }
        
        let overrideOrNil = makeOverrideIfNeededForFromStoryboardFunction(from: storyboard)
        let overrideOrEmpty = overrideOrNil == nil ? "" : overrideOrNil! + " "
        let head = "\(tab1)\(overrideOrEmpty)class func "
        if storyboardInfos.filter({ $0.storyboardName == storyboard.storyboardName }).count > 1 {
            return [
                head + "instanceFrom\(storyboard.storyboardName + storyboard.storyboardIdentifier)() -> \(name) {",
                "\(tab2)let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                "\(tab2)let viewController = storyboard.instantiateViewController(withIdentifier: \"\(storyboard.storyboardIdentifier)\") as! \(name)",
                "\(tab2)return viewController",
                "\(tab1)}"
                ].joined(separator: newLine)
        }
        
        return [
            head + "instanceFrom\(storyboard.storyboardName)() -> \(name) {",
            "\(tab2)let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
            "\(tab2)let viewController = storyboard.instantiateViewController(withIdentifier: \"\(storyboard.storyboardIdentifier)\") as! \(name)",
            "\(tab2)return viewController",
            "\(tab1)}",
            ].joined(separator: newLine)
    }
    
    func fromStoryboardForInitial(from storyboard: ViewControllerInfoOfStoryboard) -> String {
        let overrideOrNil = makeOverrideIfNeededForFromStoryboardFunction(from: storyboard)
        let overrideOrEmpty = overrideOrNil == nil ? "" : overrideOrNil! + " "
        let head = "\(tab1)\(overrideOrEmpty)class func "
        
        if storyboardInfos.filter ({ $0.isInitial }).count > 1 {
            return [
                head + "initialFrom\(storyboard.storyboardName)() -> \(name) {",
                "\(tab2)let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ",
                "\(tab2)let viewController = storyboard.instantiateInitialViewController() as! \(name)",
                "\(tab2)return viewController",
                "\(tab1)}"
                ].joined(separator: newLine)
        }
        
        return [
            head + "initialViewController() -> \(name) {",
            "\(tab2)let storyboard = UIStoryboard(name: \"\(storyboard.storyboardName)\", bundle: nil) ", 
            "\(tab2)let viewController = storyboard.instantiateInitialViewController() as! \(name)",
            "\(tab2)return viewController",
            "\(tab1)}"
            ].joined(separator: newLine)
    }
    
    func needOverrideForStoryboard(_ storyboard: ViewControllerInfoOfStoryboard) -> Bool {
        if !hasSuperClass {
            return false
        }
        
        // For initialViewController()
        let hasInitialOfSuperClass = superClassStoryboardInfos.filter({ $0.isInitial }).count > 0
        let needOverrideForInitial = hasInitialOfSuperClass && storyboard.isInitial
        if needOverrideForInitial {
            return true
        }
        
        if storyboard.storyboardIdentifier.isEmpty {
            return false
        }
        
        // For not initialViewController()
        let storyboardsForIsNotInitial = superClassStoryboardInfos.filter({ !$0.isInitial })
        return storyboardsForIsNotInitial.filter({ $0.storyboardName == storyboard.storyboardName }).count > 1
    }
    
    func needOverrideForSegue(_ storyboard: ViewControllerInfoOfStoryboard) -> Bool {
        if !hasSuperClass {
            return false
        }
        
        let superClassSegues = superClassStoryboardInfos.flatMap { $0.segues }
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
    
}
