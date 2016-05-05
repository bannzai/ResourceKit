//
//  ConfigParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/05.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct ConfigParser {
    init() {
        if let configuPath = NSBundle.mainBundle().pathForResource("ResourceKitConfig", ofType: "plist"),
            dictionary = NSDictionary(contentsOfFile: configuPath) as? [String: AnyObject] {
        }
    }
}

struct Config {
    struct Segue {
        let identifier: Bool
        let perform: Bool
        let addition: Bool
        
        init(dictionary: [Swift.String: Bool]) {
            identifier = dictionary["Identifier"] ?? false
            perform = dictionary["Perform"] ?? false
            addition = dictionary["Addition"] ?? false
        }
    }
    
    struct Image {
        let assetCatalog: Bool
        let projectResource: Bool
        
        init(dictionary: [Swift.String: Bool]) {
            assetCatalog = dictionary["AssetCatalog"] ?? false
            projectResource = dictionary["ProjectResource"] ?? false
        }
    }
    struct String {
        let localized: Bool
        
        init(dictionary: [Swift.String: Bool]) {
            localized = dictionary["Localized"] ?? false
        }
    }
    
    struct ViewController {
        let instantiateViewController: Bool
        
        init(dictionary: [Swift.String: Bool]) {
            instantiateViewController = dictionary["InstantiateViewController"] ?? false
        }
    }
    
    struct Nib {
        let xib: Bool
        
        init(dictionary: [Swift.String: Bool]) {
            xib = dictionary["Xib"] ?? false
        }
    }
    
    struct Reusable {
        let identifier: Bool
        
        init(dictionary: [Swift.String: Bool]) {
            identifier = dictionary["Identifier"] ?? false
        }
    }
}

