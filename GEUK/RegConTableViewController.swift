//
//  RegConTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 11/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class RegConTableViewController: UITableViewController {

    var selectedLocAut = ""

    fileprivate var regConResults: [[String:AnyObject]] = [[:]]
    private var constituencyName:[String] = []
    private var fullName:[String] = []
    private var partyName:[String] = []
    private var partyColour:[String] = []
    private var dataLoaded:Bool = false {
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
            regConResults = ConstituencyLocAuth.getConstituenciesForRegion(areaName: selectedLocAut, inManagedObjectContext: managedObjectContext)

            for regConResult in regConResults {
                var conName = (regConResult["constituency.constituencyName"] as! String)
                if (regConResult["wardsCon"] as! Int) != 0 {
                    conName = conName + " (" + String.localizedStringWithFormat("%d",(regConResult["wardsCon"] as! Int)) + "/"
                    conName = conName + String.localizedStringWithFormat("%d",(regConResult["wardsLA"] as! Int)) + ")"
                }
                constituencyName.append(conName)
                let onsid = (regConResult["constituency.onsid"] as! String)
                var conResult: [String:AnyObject] = [:]
                conResult = Summary.getLatestResultForConstituency(onsid: onsid, inManagedObjectContext: managedObjectContext)
                fullName.append(conResult["fullName"] as! String)
                partyName.append(conResult["partyCode"] as! String)
                partyColour.append(conResult["party.colour"] as! String)
            }
        }
        dataLoaded = true

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
        return regConResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> RegConTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! RegConTableViewCell
        cell.constituencyName.text = constituencyName[indexPath.row]
        cell.fullName.text = fullName[indexPath.row]
        cell.partyCode.text = partyName[indexPath.row]
        cell.partyColour.backgroundColor = UIColor(hexString: partyColour[indexPath.row])

        return cell
    }


}
