//
//  CollectionViewController.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/04/11.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    class var baseShoyus: [UIImage] {
        return [
            UIImage.Asset.curry,
            UIImage.Asset.ebi,
            UIImage.Asset.inaka,
            UIImage.Asset.kake,
            UIImage.Asset.kaki,
            UIImage.Asset.kikkoman,
            UIImage.Asset.koori,
            UIImage.Asset.koumi,
            UIImage.Asset.marudaizu,
            UIImage.Asset.ninniku,
            UIImage.Asset.siro,
            UIImage.Asset.ususio
        ]
    }
    
    var shoyus: [UIImage] = Array(repeating: CollectionViewController.baseShoyus, count: 10).flatMap { $0 }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(xib: CollectionViewCell.Xib.self)
        collectionView?.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != CollectionViewController.Segue.showViewController {
            fatalError("\(#file) + \(#function) + \(#line)")
        }
        
        segue.destination.title = sender as? String
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoyus.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.Xib.name, for: indexPath) as! CollectionViewCell // TODO: Support Generics Type
        cell.setupWith(shoyus[indexPath.item]) // TODO: Support UIImage Name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - 2
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegueShowViewController()
    }



}
