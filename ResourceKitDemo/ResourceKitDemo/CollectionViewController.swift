//
//  CollectionViewController.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/04/11.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    class var baseShoyus: [String] {
        return [
            "curry",
            "ebi",
            "inaka",
            "kake",
            "kaki",
            "kikkoman",
            "koori",
            "koumi",
            "marudaizu",
            "ninniku",
            "siro",
            "ususio"
        ]
    }
    
    var shoyus: [String] = Array(count: 10, repeatedValue: CollectionViewController.baseShoyus).flatMap { $0 }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.registerNib(CollectionViewCell.Xib())
        collectionView?.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != CollectionViewController.Segue.showViewController {
            fatalError()
        }
        
        segue.destinationViewController.title = sender as? String
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoyus.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCell.Xib().name, forIndexPath: indexPath) as! CollectionViewCell // TODO: Support Generics Type
        cell.setupWith(shoyus[indexPath.item]) // TODO: Support UIImage Name
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = CGRectGetWidth(UIScreen.mainScreen().bounds) / 3 - 2
        return CGSizeMake(width, width)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        perFormSegueShowViewController("Title")
    }



}
