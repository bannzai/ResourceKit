//
//  Project.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/04/07.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

public class ProjectResource {
    public static let shared: ProjectResource = ProjectResource()
    
    fileprivate init() { }
    
    public fileprivate(set) var paths: [URL] = []
    public fileprivate(set) var localizablePaths: [URL] = []
    
    public var viewControllers: [ViewController] = []
    
    public fileprivate(set) var tableViewCells: [TableViewCell] = []
    public fileprivate(set) var collectionViewCells: [CollectionViewCell] = []
    public fileprivate(set) var xibs: [Xib] = []
}

extension ProjectResource: AppendableForPaths {
    public func appendFileReferencePaths(urls: [URL]) {
        paths.append(contentsOf: urls)
    }
    
    public func appendLocalizedPaths(urls: [URL]) {
        localizablePaths.append(contentsOf: urls)
    }
}

extension ProjectResource: AppendableForXibs {
    public func appendXib(_ xib: Xib) {
        if xibs.contains(where: { $0.className == xib.className }) {
            return
        }
        xibs.append(xib)
    }
}

extension ProjectResource: AppendableForStoryboard {
    public func appendTableViewCell(_ className: String, reusableIdentifier: String) {
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
        
        cell.reusableIdentifiers.insert(reusableIdentifier)
    }
    
    public func appendCollectionViewCell(_ className: String, reusableIdentifier: String) {
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
        
        cell.reusableIdentifiers.insert(reusableIdentifier)
    }
    
    public func appendViewControllerInfoReference(_ className: String?, viewControllerInfo: ViewControllerInfoOfStoryboard) {
        viewControllers
            .filter({ $0.name == className })
            .first?
            .storyboardInfos
            .append(viewControllerInfo)
    }
}
