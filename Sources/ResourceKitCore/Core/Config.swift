//
//  Config.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/05.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

public protocol Config {
    var segue: ConfigType.Segue { get }
    var image: ConfigType.Image { get }
    var string: ConfigType.LocalizedString { get }
    var viewController: ConfigType.ViewController { get }
    var nib: ConfigType.Nib { get }
    var reusable: ConfigType.Reusable { get }
    var needGenerateSegue: Bool { get }
}

public struct ConfigImpl: Config {
    public private(set) var segue: ConfigType.Segue = ConfigType.Segue()
    public private(set) var image: ConfigType.Image = ConfigType.Image()
    public private(set) var string: ConfigType.LocalizedString = ConfigType.LocalizedString()
    public private(set) var viewController: ConfigType.ViewController = ConfigType.ViewController()
    public private(set) var nib: ConfigType.Nib = ConfigType.Nib()
    public private(set) var reusable: ConfigType.Reusable = ConfigType.Reusable()
    
    public var needGenerateSegue: Bool {
        return segue.addition || segue.standard
    }
    
    public init(outputPath: String) {
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
                case .LocalizedString:
                    string = ConfigType.LocalizedString(value as? [String: Bool] ?? [:])
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

public struct ConfigType {
    public enum Item: Swift.String {
        case Segue
        case Image
        case LocalizedString
        case ViewController
        case Nib
        case Reusable
    }
    
    public struct Segue {
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
    
    public struct Image {
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
    
    public struct LocalizedString {
        public let localized: Bool
        
        init() {
            localized = true
        }
        init(_ dictionary: [Swift.String: Bool]) {
            localized = dictionary["Localized"] ?? false
        }
    }
    
    public struct ViewController {
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
    
    public struct Nib {
        public let xib: Bool
        
        init() {
            xib = true
        }
        init(_ dictionary: [Swift.String: Bool]) {
            xib = dictionary["Xib"] ?? false
        }
    }
    
    public struct Reusable {
        public let identifier: Bool
        
        init() {
            identifier = true
        }
        init(_ dictionary: [Swift.String: Bool]) {
            identifier = dictionary["Identifier"] ?? false
        }
    }
}

