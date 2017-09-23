//
//  ConfigType.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/05.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

protocol Config {
    var segue: ConfigType.Segue { get }
    var image: ConfigType.Image { get }
    var string: ConfigType.String { get }
    var viewController: ConfigType.ViewController { get }
    var nib: ConfigType.Nib { get }
    var reusable: ConfigType.Reusable { get }
    var needGenerateSegue: Bool { get }
}

struct ConfigImpl: Config {
    private(set) var segue: ConfigType.Segue = ConfigType.Segue()
    private(set) var image: ConfigType.Image = ConfigType.Image()
    private(set) var string: ConfigType.String = ConfigType.String()
    private(set) var viewController: ConfigType.ViewController = ConfigType.ViewController()
    private(set) var nib: ConfigType.Nib = ConfigType.Nib()
    private(set) var reusable: ConfigType.Reusable = ConfigType.Reusable()
    
    var needGenerateSegue: Bool {
        return segue.addition || segue.standard
    }
    
    init() {
        if let dictionary = NSDictionary(contentsOfFile: outputPath + "/ResourceKitConfig.plist") as? [String: AnyObject] {
            dictionary.forEach { (key: String , value: AnyObject) in
                guard let item = ConfigType.Item(rawValue: key) else {
                    return
                }
                switch item {
                case .Segue:
                    segue = ConfigType.Segue(value as? [String: Bool] ?? [:])
                case .Image:
                    image = ConfigType.Image(value as? [String: Bool] ?? [:])
                case .String:
                    string = ConfigType.String(value as? [String: Bool] ?? [:])
                case .ViewController:
                    viewController = ConfigType.ViewController(value as? [String: Bool] ?? [:])
                case .Nib:
                    nib = ConfigType.Nib(value as? [String: Bool] ?? [:])
                case .Reusable:
                    reusable = ConfigType.Reusable(value as? [String: Bool] ?? [:])
                }
            }
        }
    }
}

struct ConfigType {
    enum Item: Swift.String {
        case Segue
        case Image
        case String
        case ViewController
        case Nib
        case Reusable
    }
    
    struct Segue {
        let standard: Bool
        let addition: Bool
        
        init() {
            standard = true
            addition = false
        }
        init(_ dictionary: [Swift.String: Bool]) {
            standard = dictionary["Standard"] ?? false
            addition = dictionary["Addition"] ?? false
        }
    }
    
    struct Image {
        let assetCatalog: Bool
        let projectResource: Bool
        
        init() {
            assetCatalog = true
            projectResource = true
        }
        init(_ dictionary: [Swift.String: Bool]) {
            assetCatalog = dictionary["AssetCatalog"] ?? false
            projectResource = dictionary["ProjectResource"] ?? false
        }
    }
    
    struct String {
        let localized: Bool
        
        init() {
            localized = true
        }
        init(_ dictionary: [Swift.String: Bool]) {
            localized = dictionary["Localized"] ?? false
        }
    }
    
    struct ViewController {
        let instantiateStoryboardForSwift: Bool
        let instantiateStoryboardForObjC: Bool
        
        var instantiateStoryboardAny: Bool {
            return instantiateStoryboardForSwift || instantiateStoryboardForObjC
        }
        
        init() {
            instantiateStoryboardForSwift = true
            instantiateStoryboardForObjC = true
        }
        init(_ dictionary: [Swift.String: Bool]) {
            instantiateStoryboardForSwift = dictionary["InstantiateStoryboardForSwift"] ?? false
            instantiateStoryboardForObjC = dictionary["InstantiateStoryboardForObjC"] ?? false
        }
    }
    
    struct Nib {
        let xib: Bool
        
        init() {
            xib = true
        }
        init(_ dictionary: [Swift.String: Bool]) {
            xib = dictionary["Xib"] ?? false
        }
    }
    
    struct Reusable {
        let identifier: Bool
        
        init() {
            identifier = true
        }
        init(_ dictionary: [Swift.String: Bool]) {
            identifier = dictionary["Identifier"] ?? false
        }
    }
}

