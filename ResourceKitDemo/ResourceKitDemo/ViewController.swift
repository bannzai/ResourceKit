//
//  ViewController.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/04/10.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(CustomView.Xib().fromNib())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != ViewController.Segue.showSecondTable {
            fatalError()
        }
    }
    @IBAction func tappedSecondCollectionView() {
        navigationController?.pushViewController(SecondCollectionViewController.instanceFromTabBarController(), animated: true)
    }
    
    @IBAction func tappedSecondTableView() {
        perFormSegueShowSecondTable()
    }
}

