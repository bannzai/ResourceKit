//
//  project.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/04/07.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

class ProjectResource {
    static let sharedInstance: ProjectResource = ProjectResource()
    private init() { }
    var viewControllers: [ViewController] = []
    var tableViewCells: [TableViewCell] = []
    var collectionViewCells: [CollectionViewCell] = []
    var xibs: [XibForView] = []
    var xibIdentifiers = [String]()
    
    func appendTableViewCell(className: String, reusableIdentifier: String) {
        guard let cell = tableViewCells
            .filter ({ $0.className == className})
            .first else {
                tableViewCells.append(
                    TableViewCell(
                        reusableIdentifier: reusableIdentifier,
                        className: className
                    )
                )
                return
        }
        
        if cell.reusableIdentifiers.contains({ $0 == reusableIdentifier }) {
            return
        }
        
        cell.reusableIdentifiers.append(reusableIdentifier)
    }
    
    func appendCollectionViewCell(className: String, reusableIdentifier: String) {
        guard let cell = collectionViewCells
            .filter ({ $0.className == className})
            .first else {
                collectionViewCells.append(
                    CollectionViewCell (
                        reusableIdentifier: reusableIdentifier,
                        className: className
                    )
                )
                return
        }
        
        if cell.reusableIdentifiers.contains({ $0 == reusableIdentifier }) {
            return
        }
        
        cell.reusableIdentifiers.append(reusableIdentifier)
    }
    
    func appendXibForView(xib: XibForView) {
        if xibs.contains({ $0.className == xib.className }) {
            return
        }
        xibs.append(xib)
    }
    
}

