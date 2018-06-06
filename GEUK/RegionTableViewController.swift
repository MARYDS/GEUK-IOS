//
//  RegionTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 11/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class RegionTableViewController: UITableViewController {

    var selectedRegion:String = "UK Wide"

    fileprivate var regionResults:[String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var lastSelected:IndexPath = IndexPath(row:0,section:0)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        
        updateUI()
        
        tableView.estimatedRowHeight = 35.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    private func updateUI() {
        
        // Load available election years from database
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        {
            regionResults = Constituency.getRegions(inManagedObjectContext: managedObjectContext)
        }
        // Make the cell self size
        tableView.estimatedRowHeight = 35.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "regionCell", for: indexPath)
        cell.textLabel?.text = regionResults[indexPath.row]
        if cell.textLabel?.text == selectedRegion {
            cell.accessoryType = .checkmark
            cell.setSelected(true, animated: false)
            lastSelected = indexPath
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)!
        currentCell.accessoryType = .none
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let last = tableView.cellForRow(at:lastSelected) {
            last.accessoryType = .none
        }
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        selectedRegion = currentCell.textLabel!.text!
        currentCell.accessoryType = .checkmark
        lastSelected = indexPath
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let send = sender as? UITableViewCell {
            selectedRegion = send.textLabel!.text!
        }
    }

}
