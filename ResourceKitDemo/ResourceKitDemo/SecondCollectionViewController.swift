//
//  SecondCollectionViewController.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/04/11.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import UIKit

class SecondCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 100
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SecondCollectionViewCell.Reusable.ReuseIdentifier, for: indexPath) as! SecondCollectionViewCell
        cell.label.text = "\(indexPath.item)"
        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(OverrideViewController.initialViewController(), animated: true)
    }

}
