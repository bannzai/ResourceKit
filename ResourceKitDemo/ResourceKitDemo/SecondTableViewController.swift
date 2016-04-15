//
//  SecondTableViewController.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/04/11.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import UIKit

class SecondTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 40
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SecondTableViewCell.Reusable.ReuseIdentifier, forIndexPath: indexPath) as! SecondTableViewCell
        cell.label.text = "Second"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        perFormSegueShowOverride()
    }
}
