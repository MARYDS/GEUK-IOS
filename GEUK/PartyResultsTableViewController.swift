//
//  PartyResultsTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 02/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class PartyResultsTableViewController: UITableViewController, YearRegionDelegate {

    private var electionYear = "" {
        didSet {
            updateUI()
        }
    }
    
    private var regionName = "UK Wide" {
        didSet {
            updateUI()
        }
    }
    
    fileprivate var partyResults:[[String:AnyObject]] = [[:]] {
        didSet {
            tableView.reloadData()
        }
    }

    var euResultsDelegate: YearRegionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        updateUI()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateUI()
    }
    
    internal func setElectionYear(year: String) {
        electionYear = year
    }
    
    internal func setRegion(region: String) {
        regionName = region
    }
    
    
    private func updateUI() {
        
        title = electionYear + " " + regionName
        
        // Load party summary results from database
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        {
            partyResults = PartySummary.getBasicAllPartyResults(year: electionYear, region: regionName, sortOrder: ["seats","votes","party.name"], sortAsc: [false,false,true], inManagedObjectContext: managedObjectContext)
        }

        // Make the cell self size
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let  footer = tableView.dequeueReusableCell(withIdentifier: "sectionFooter")! as! PartyResultsFooterTableViewCell
        let basedOnYear = electionYear.substring(to: electionYear.index(electionYear.startIndex, offsetBy:4))
        if electionYear.contains("+") {
            footer.data1.text = "Election information based on news reports"
        } else {
            if basedOnYear == "2010" {
                footer.data1.text = "Election information based on Electoral Commission, UK Parliament general election, published 6 May 2010."
            } else {
                footer.data1.text = "Election information based on House of Commons library data"
            }
        }
        tableView.tableFooterView = footer
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partyResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! PartyResultsTableViewCell
        
        // Configure the cell...
        cell.partyColor.text = " "
        cell.partyColor.backgroundColor = UIColor(hexString: (partyResults[indexPath.row]["party.colour"] as! String))
        cell.partyName.text = (partyResults[indexPath.row]["party.name"] as! String)
        cell.seats.text = String.localizedStringWithFormat(" %d",partyResults[indexPath.row]["seats"] as! Int)
        cell.candidates.text = String.localizedStringWithFormat(" %d",partyResults[indexPath.row]["candidates"] as! Int)
        cell.votes.text = String.localizedStringWithFormat(" %d",partyResults[indexPath.row]["votes"] as! Int)
        cell.votesPercent.text = String.localizedStringWithFormat(" %.02f",partyResults[indexPath.row]["votesPercent"] as! Double)
        if (partyResults[indexPath.row]["changePercent"] as! Double) == 0.0 {
            cell.changePercent.text = ""
        } else {
            cell.changePercent.text = String.localizedStringWithFormat(" %.02f",partyResults[indexPath.row]["changePercent"] as! Double)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")!
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            var dc = segue.destination
            if let nc = dc as? UINavigationController {
                dc = nc.visibleViewController ?? dc
            }
            switch identifier {
            case "showReferendum" :
                if let vc = dc as? EUTableViewController {
                    euResultsDelegate = vc
                    euResultsDelegate?.setElectionYear(year: electionYear)
                    euResultsDelegate?.setRegion(region: regionName)
                }
            default: break
            }
        }
    }
   
}
