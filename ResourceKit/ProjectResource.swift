//
//  Project.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/04/07.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

class ProjectResource {
    static let shared: ProjectResource = ProjectResource()
    
    fileprivate init() { }
    
    fileprivate(set) var paths: [URL] = []
    fileprivate(set) var localizablePaths: [URL] = []
    
    var viewControllers: [ViewController] = []
    fileprivate(set) var tableViewCells: [TableViewCell] = []
    fileprivate(set) var collectionViewCells: [CollectionViewCell] = []
    fileprivate(set) var xibs: [XibForView] = []
}

extension ProjectResource: AppendableForPaths {
    func appendFileReferencePaths(urls: [URL]) {
        paths.append(contentsOf: urls)
    }
    
    func appendLocalizedPaths(urls: [URL]) {
        localizablePaths.append(contentsOf: urls)
    }
}

extension ProjectResource: AppendableForXibs {
    func appendXibForView(_ xib: XibForView) {
        if xibs.contains(where: { $0.className == xib.className }) {
            return
        }
        xibs.append(xib)
    }
}

extension ProjectResource: AppendableForStoryboard {
    func appendTableViewCell(_ className: String, reusableIdentifier: String) {
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
        
        if cell.reusableIdentifiers.contains(where: { $0 == reusableIdentifier }) {
            return
        }
        
        cell.reusableIdentifiers.append(reusableIdentifier)
    }
    
    func appendCollectionViewCell(_ className: String, reusableIdentifier: String) {
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
        
        if cell.reusableIdentifiers.contains(where: { $0 == reusableIdentifier }) {
            return
        }
        
        cell.reusableIdentifiers.append(reusableIdentifier)
    }
    
    func appendViewControllerInfoReference(_ className: String, viewControllerInfo: ViewControllerInfoOfStoryboard) {
        viewControllers
            .filter({ $0.name == className })
            .first?
            .storyboardInfos
            .append(viewControllerInfo)
    }
}
