//
//  EUTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 29/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

class EUTableViewController: UITableViewController, YearRegionDelegate {
    
    private var electionYear = ""
    
    private var regionName = "UK Wide" {
        didSet {
            updateUI()
        }
    }
    
    fileprivate var EUResults:[[String:AnyObject]]  = [[:]] {
        didSet {
            tableView.reloadData()
        }
    }

    private var sortColumns = ["Region", "Local Authority", "Electorate", "Turnout%", "Remain", "Remain%", "Leave", "Leave%"]  {
        didSet {
            updateUI()
        }
    }
    private let leaveColour = UIColor(hexString: "#0087DCFF")
    private let remainColour = UIColor(hexString: "#FDBB30FF")
    
    @IBAction private func showEUSort(_ sender: Any) {
        self.performSegue(withIdentifier: "showEUSort", sender: sender)
    }
    
    private var sortAsc = [true, true, false, false, false, false, false, false]

    private var totalRemain = 0
    private var totalLeave = 0
    private var totalVotes = 0
    private var totalElectorate = 0
    private var turnoutPercent = 0.0
    private var remainPercent = 0.0
    private var leavePercent = 0.0

    private var selectedArea = ""

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

        title = "EU Referendum " + regionName

        // Get the EU results
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        {
            EUResults = EUReferendum.getBasicAllReferendumResults(region: regionName, sortOrder: sortColumns, sortAsc: sortAsc, inManagedObjectContext: managedObjectContext)
            
            totalRemain = 0
            totalLeave = 0
            totalVotes = 0
            totalElectorate = 0
            for EUResult in EUResults {
                totalRemain += EUResult["remainVotes"] as! Int
                totalLeave += EUResult["leaveVotes"] as! Int
                totalElectorate += EUResult["electorate"] as! Int
            }
            totalVotes = totalRemain + totalLeave
            turnoutPercent = (Double(totalVotes) / Double(totalElectorate) ) * 100.0
            remainPercent = (Double(totalRemain) / Double(totalVotes)) * 100.0
            leavePercent = (Double(totalLeave) / Double(totalVotes)) * 100
            
        }
        
        // Make the cell self size
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let  footer = tableView.dequeueReusableCell(withIdentifier: "sectionFooter")! as! EUFooterTableViewCell
        footer.data1.text = "Results based on Electoral Commission, Referendum on the UK's membership of the EU, published 23 June 2016."
        tableView.tableFooterView = footer
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return EUResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! EUDetailTableViewCell

        // Configure the cell...
        cell.region.text = (EUResults[indexPath.row]["region"] as! String)
        cell.areaName.text = (EUResults[indexPath.row]["areaName"] as! String)
        cell.electorate.text = String.localizedStringWithFormat(" %d",EUResults[indexPath.row]["electorate"] as! Int)
        cell.turnout.text = String.localizedStringWithFormat(" %.02f",EUResults[indexPath.row]["turnoutPercent"] as! Double)
        cell.remain.text = String.localizedStringWithFormat(" %d",EUResults[indexPath.row]["remainVotes"] as! Int)
        cell.remainPercent.text = String.localizedStringWithFormat(" %.02f",EUResults[indexPath.row]["remainPercent"] as! Double)
        cell.leave.text = String.localizedStringWithFormat(" %d",EUResults[indexPath.row]["leaveVotes"] as! Int)
        cell.leavePercent.text = String.localizedStringWithFormat(" %.02f",EUResults[indexPath.row]["leavePercent"] as! Double)
        
        if (EUResults[indexPath.row]["remainVotes"] as! Int) > (EUResults[indexPath.row]["leaveVotes"] as! Int) {
            cell.EUColour.backgroundColor = remainColour
        } else {
            cell.EUColour.backgroundColor = leaveColour
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "sectionHeader")! as! EUHeaderTableViewCell
        
        header.totalElectorate.text = String.localizedStringWithFormat(" %d",totalElectorate)
        header.totalVotes.text = String.localizedStringWithFormat(" %d",totalVotes)
        header.turnout.text = String.localizedStringWithFormat(" %.02f",turnoutPercent)
        header.remainVotes.text = String.localizedStringWithFormat(" %d",totalRemain)
        header.leaveVotes.text = String.localizedStringWithFormat(" %d",totalLeave)
        header.remainPercent.text = String.localizedStringWithFormat(" %.02f",remainPercent)
        header.leavePercent.text = String.localizedStringWithFormat(" %.02f",leavePercent)

        // Pie-chart for EU results
        let pieChartView = PieChartView()
        pieChartView.frame = CGRect(x: view.frame.size.width * 3/4, y: 5, width: view.frame.size.width/3, height: 80)
        var segment: Segment = Segment(color: leaveColour!, value: CGFloat(totalLeave))
        pieChartView.segments.append(segment)
        segment = Segment(color: remainColour!, value: CGFloat(totalRemain))
        pieChartView.segments.append(segment)
        header.addSubview(pieChartView)
 
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!)! as! EUDetailTableViewCell
        selectedArea = currentCell.areaName.text!
        self.performSegue(withIdentifier: "showConstituency", sender: currentCell)
    }
    
    @IBAction func unwindToEUResultsList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EUSortTableViewController {
            sortAsc = sourceViewController.sortAsc
            sortColumns = sourceViewController.sortColumns
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            var dc = segue.destination
            if let nc = dc as? UINavigationController {
                dc = nc.visibleViewController ?? dc
            }
            switch identifier {
            case "showEUSort" :
                if let vc = dc as? EUSortTableViewController {
                    vc.sortColumns = sortColumns
                    vc.sortAsc = sortAsc
                }
            case "showConstituency" :
                if let vc = dc as? RegConTableViewController {
                    vc.selectedLocAut = selectedArea
                }
            default: break
            }
        }
        
    }


}
