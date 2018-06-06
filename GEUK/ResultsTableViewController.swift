//
//  ResultsTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 25/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

protocol YearRegionDelegate: class {
    func setElectionYear(year: String)
    func setRegion(region: String)
}
protocol ConstituencyDelegate: class {
    func setConstituency(onsid: String, constituencyName: String)
}
protocol ReloadDelegate: class {
    func reloadData()
}

class ResultsTableViewController: UITableViewController, UISearchBarDelegate, SimulateTableViewControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    weak var simulatorDelegate : YearRegionDelegate?
    weak var partyResultsDelegate: YearRegionDelegate?
    weak var euResultsDelegate: YearRegionDelegate?
    weak var detailYearDelegate: YearRegionDelegate?
    weak var detailConstituencynDelegate: ConstituencyDelegate?
    weak var detailReloadDelegate : ReloadDelegate?
    
    private var calledFromSearch = false

    var electionYear = "2017" {
        didSet {
            updateUI()
            tableView.reloadData()
            let year = electionYear.substring(to: electionYear.index(electionYear.startIndex, offsetBy:4))
            simulatorDelegate?.setElectionYear(year: year)
            partyResultsDelegate?.setElectionYear(year: electionYear)
            euResultsDelegate?.setElectionYear(year: year)
            detailYearDelegate?.setElectionYear(year: electionYear)
        }
    }

    var selectedRegion = "UK Wide" {
        didSet {
            updateUI()
            tableView.reloadData()
            simulatorDelegate?.setRegion(region: selectedRegion)
            partyResultsDelegate?.setRegion(region: selectedRegion)
            euResultsDelegate?.setRegion(region: selectedRegion)
        }
    }

    fileprivate var summaryResults: [[String:AnyObject]] = [[:]] {
        didSet {
            tableView.reloadData()
        }
    }
    var sortColumns :[String] = ["Region", "Constituency", "Winning Party", "Elected MP", "Majority %", "Previous Party", "Runner-up Party", "Party Changed"]  {
        didSet {
            updateUI()
            tableView.reloadData()
        }
    }
    
    private var collapseDetailViewController = true
    
    @IBAction private func showYear(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showYear", sender: sender)
    }
    
    @IBAction private func showRegion(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showRegion", sender: sender)
    }
    
    @IBAction private func showSort(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showSort", sender: sender)
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        
        let minimumWidth : CGFloat = min((splitViewController!.view.bounds).width,(splitViewController!.view.bounds).height)
        splitViewController?.minimumPrimaryColumnWidth = minimumWidth * 0.45
        splitViewController?.maximumPrimaryColumnWidth = minimumWidth * 0.55
 
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 35
        
        updateUI()

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateUI()
    }
    
    // This method reloads the table based on the search
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        calledFromSearch = true
        updateUI()
        calledFromSearch = false
    }
    
    private func updateUI() {

        self.title = electionYear + " General Election"
        
        // Load summary results from database
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        {
            summaryResults = Summary.getBasicSummariesForElectionRegion(year: electionYear, region: selectedRegion, sortColumns: sortColumns, searchText: searchBar.text!, inManagedObjectContext: managedObjectContext)
        }
        
        // Select the first detail item
        if summaryResults.count > 0 && calledFromSearch == false {
            if self.splitViewController!.viewControllers.count > 1 {
                if let navVC: UINavigationController =  self.splitViewController!.viewControllers[1] as? UINavigationController {
                    if let detvc = navVC.topViewController as? DetailTableViewController {
                        
                        let rowToSelect = IndexPath(row: 0, section: 0)
                        self.tableView.selectRow(at: rowToSelect, animated: true, scrollPosition:UITableViewScrollPosition.none)
                        
                        detailReloadDelegate = detvc
                        detailYearDelegate = detvc
                        detailYearDelegate?.setElectionYear(year: electionYear)
                        if let selRow = self.tableView.cellForRow(at: rowToSelect) as? ResultsTableViewCell {
                            detailConstituencynDelegate = detvc
                            detailConstituencynDelegate?.setConstituency(onsid: selRow.onsid.text!, constituencyName: selRow.constituency.text!)
                        }
                        
                    }
                }
            }
            
        }
        
        let  footer = tableView.dequeueReusableCell(withIdentifier: "sectionFooter")! as! ResultsFooterTableViewCell
        let basedOnYear = electionYear.substring(to: electionYear.index(electionYear.startIndex, offsetBy:4))
        if electionYear.contains("+") {
            footer.data1.text = "Election information based on news reports"
        } else {if basedOnYear == "2010" {
                footer.data1.text = "Election information based on Electoral Commission, UK Parliament general election, published 6 May 2010."
            } else if basedOnYear == "2015" {
                footer.data1.text = "Election information based on House of Commons library data"
            } else if basedOnYear == "2017" {
                footer.data1.text = "Election information based on House of Commons library data"
            }
        }
        tableView.tableFooterView = footer
        
    }

    override internal func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summaryResults.count
    }

    override internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as! ResultsTableViewCell
     
        // Configure the cell...
        cell.year.text = (summaryResults[indexPath.row]["year"] as! String)
        cell.onsid.text = (summaryResults[indexPath.row]["onsid"] as! String)
        cell.constituency.text = (summaryResults[indexPath.row]["constituency.constituencyName"] as! String)
        cell.region.text = (summaryResults[indexPath.row]["constituency.regionName"] as! String)
        cell.party.text = (summaryResults[indexPath.row]["party.name"] as! String)
        var col = (summaryResults[indexPath.row]["party.colour"] as! String)
        cell.partyColour.backgroundColor = UIColor(hexString: col)
        cell.partyColour1.backgroundColor = UIColor(hexString: col)
        cell.name.text = (summaryResults[indexPath.row]["fullName"] as! String)
        cell.majoritypercent.text = String.localizedStringWithFormat(" %.01f", (summaryResults[indexPath.row]["majorityPercent"] as! Double))
        col = (summaryResults[indexPath.row]["runnerupparty.colour"] as! String)
        cell.runnerUpColor.backgroundColor = UIColor(hexString: col)
        cell.runnerUpColor1.backgroundColor = UIColor(hexString: col)
        col = (summaryResults[indexPath.row]["prevParty.colour"] as! String)
        cell.prevColor.backgroundColor = UIColor(hexString: col)
        cell.prevColor1.backgroundColor = UIColor(hexString: col)
        return cell
    }

    override internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "sectionHeader")! as! ResultsHeaderTableViewCell

        return header
    }
    
    override internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110
    }

    @IBAction func unwindToResultsList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SortTableViewController {
            sortColumns = sourceViewController.sortColumns
        }
        if let sourceViewController = sender.source as? YearTableViewController {
            if sourceViewController.selectedYear != "" {
                electionYear = sourceViewController.selectedYear
            }
        }
        if let sourceViewController = sender.source as? RegionTableViewController {
            if sourceViewController.selectedRegion != "" {
                selectedRegion = sourceViewController.selectedRegion
            }
        }
        if let _ = sender.source as? DetailTableViewController {
            self.splitViewController?.toggleMasterView()
            detailReloadDelegate?.reloadData()
        }
        if let _ = sender.source as? EUTableViewController {
            self.splitViewController?.toggleMasterView()
        }
        if let _ = sender.source as? PartyResultsTableViewController {
            self.splitViewController?.toggleMasterView()
        }
        if let _ = sender.source as? SimulateTableViewController {
            self.splitViewController?.toggleMasterView()
        }
        if let _ = sender.source as? WebViewController {
            self.splitViewController?.toggleMasterView()
        }

    }
    
    override internal func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            var dc = segue.destination
            if let nc = dc as? UINavigationController {
                dc = nc.visibleViewController ?? dc
            }
            switch identifier {
            case "showDetail" :
                if let vc = dc as? DetailTableViewController {
                    if let send = sender as? ResultsTableViewCell {
                        detailReloadDelegate = vc
                        detailYearDelegate = vc
                        detailYearDelegate?.setElectionYear(year: send.year.text!)
                        detailConstituencynDelegate = vc
                        detailConstituencynDelegate?.setConstituency(onsid: send.onsid.text!, constituencyName: send.constituency.text!)
                        self.splitViewController?.toggleMasterView()
                    }
                }
            case "showSort" :
                if let vc = dc as? SortTableViewController {
                     vc.sortColumns = sortColumns
                }
                
                
            case "showYear" :
                if let vc = dc as? YearTableViewController {
                    vc.selectedYear = electionYear
                }
                
            case "showRegion" :
                if let vc = dc as? RegionTableViewController {
                    vc.selectedRegion = selectedRegion
                }
    
            case "showSummary" :
                if let vc = dc as? PartyResultsTableViewController {
                    partyResultsDelegate = vc
                    partyResultsDelegate?.setElectionYear(year: electionYear)
                    partyResultsDelegate?.setRegion(region: selectedRegion)
                    self.splitViewController?.toggleMasterView()
                }

            case "showSimulator" :
                if let vc = dc as? SimulateTableViewController {
                    simulatorDelegate = vc
                    simulatorDelegate?.setElectionYear(year: electionYear.substring(to: electionYear.index(electionYear.startIndex, offsetBy:4)))
                    simulatorDelegate?.setRegion(region: selectedRegion)
                    vc.delegate = self
                    self.splitViewController?.toggleMasterView()
                }
            case "showReferendum" :
                if let vc = dc as? EUTableViewController {
                    euResultsDelegate = vc
                    euResultsDelegate?.setElectionYear(year: electionYear)
                    euResultsDelegate?.setRegion(region: selectedRegion)
                    self.splitViewController?.toggleMasterView()
                }
            case "showWeb" :
                if let _ = dc as? WebViewController {
                    self.splitViewController?.toggleMasterView()
                }


            default: break
            }
        }
    }
    
    internal func reloadResults(year: String) {
        electionYear = year
    }
    
}
extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
    }
}
