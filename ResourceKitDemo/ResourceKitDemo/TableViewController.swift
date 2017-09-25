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
        String.Localized.hello_world_4,
        String.Localized.hello_world_07,
        String.Localized.hello_world_2,
        String.Localized.hello_world_10,
        String.Localized.hello_world_09,
        String.Localized.hello_world_08,
        String.Localized.hello_world_06,
        String.Localized.hello_world_1,
        String.Localized.hello_world_05,
        String.Localized.helloworld,
        String.Localized.hello_world_3
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(xib: TableViewCell.Xib.self)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return localized.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.Xib.name, for: indexPath) // TODO: Support Generics Type
        cell.textLabel?.text = localized[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(ViewController.initialViewController(), animated: true)
    }
}
