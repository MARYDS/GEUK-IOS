//
//  EUSortTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 30/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class EUSortTableViewController: UITableViewController {

    var sortColumns :[String] = []
    var sortAsc :[Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        tableView.estimatedRowHeight = 35.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.setEditing(true, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortColumns.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath)
        cell.textLabel?.text = sortColumns[indexPath.row]
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            sortColumns.remove(at: indexPath.row)
            sortAsc.remove(at: indexPath.row)
        } else if editingStyle == .insert {
            // Do not support insert
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let item : String = sortColumns[fromIndexPath.row];
        sortColumns.remove(at: fromIndexPath.row);
        sortColumns.insert(item, at: to.row)
        let sortOrder = sortAsc[fromIndexPath.row]
        sortAsc.remove(at: fromIndexPath.row);
        sortAsc.insert(sortOrder, at: to.row)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
}
