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
        view.addSubview(CustomView.Xib.view())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != ViewController.Segue.showSecondTable {
            fatalError("\(#file) + \(#function) + \(#line)")
        }
    }
    @IBAction func tappedSecondCollectionView() {
        navigationController?.pushViewController(SecondCollectionViewController.instanceFromTabBarController(), animated: true)
    }
    
    @IBAction func tappedSecondTableView() {
        performSegueShowSecondTable()
    }
}

