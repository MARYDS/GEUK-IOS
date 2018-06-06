//
//  WardConTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 11/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class WardConTableViewController: UITableViewController {

    var onsid = ""

    fileprivate var wardConResults: [WardConLocAuth] = [] {
        didSet {
            tableView.reloadData()
        }
    }

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
            wardConResults = WardConLocAuth.getWardList(onsid: onsid, sortOrder: ["areaName","wardName"], sortAsc: [true,true], inManagedObjectContext: managedObjectContext)
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
        return wardConResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> WardConTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! WardConTableViewCell
        cell.areaName.text = wardConResults[indexPath.row].areaName
        cell.wardName.text = wardConResults[indexPath.row].wardName

        return cell
    }


}
