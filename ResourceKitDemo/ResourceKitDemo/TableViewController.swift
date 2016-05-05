//
//  TableViewController.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/04/11.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    let localized = [
        String.Localizable.hello_world_4,
        String.Localizable.hello_world_07,
        String.Localizable.hello_world_2,
        String.Localizable.hello_world_10,
        String.Localizable.hello_world_09,
        String.Localizable.hello_world_08,
        String.Localizable.hello_world_06,
        String.Localizable.hello_world_1,
        String.Localizable.hello_world_05,
        String.Localizable.hello_world,
        String.Localizable.hello_world_3
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(TableViewCell.Xib())
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return localized.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCell.Xib().name, forIndexPath: indexPath) // TODO: Support Generics Type
        cell.textLabel?.text = localized[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(ViewController.initialViewController(), animated: true)
    }
}
