//
//  DetailTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 28/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit


class DetailTableViewController: UITableViewController, YearRegionDelegate, ConstituencyDelegate, ReloadDelegate {
    
    private var electionYear = ""
    private var constituencyName = ""
    private var compareYear = ""
    
    private var onsid = "" {
        didSet {
            updateUI()
            tableView.reloadData()
        }
    }
    
    fileprivate var detailResults:[[String:AnyObject]] = [[:]] {
        didSet {
            tableView.reloadData()
        }
    }
    
    fileprivate var compareResults:[[String:AnyObject]] = [[:]]
    fileprivate var summaryResults:[[String:AnyObject]] = []
    
    @IBAction private func chooseCompare(_ sender: UIButton) {
        if compareYear != "" {
            electionYear = compareYear
            updateUI()
        }
    }

    @IBAction func showWards(_ sender: Any) {
        self.performSegue(withIdentifier: "showWards", sender: sender)
    }
    
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
        
    }
    
    internal func setConstituency(onsid: String, constituencyName: String) {
        self.constituencyName = constituencyName
        self.onsid = onsid
    }
    
    internal func reloadData() {
        updateUI()
    }
    
    private func updateUI() {
        
        title = electionYear + " " + constituencyName
        
        // Load summary results from database
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        {
            
            // Get Summary results for constituency
            summaryResults = Summary.getBasicSummaryForElectionConstituency(year: electionYear, onsid: onsid, inManagedObjectContext: managedObjectContext)
            
            // Get detail results for constituency
            detailResults = Detail.getBasicDetailsForConstituency(year: electionYear, constituency: onsid, sortOrder: ["votes"], sortAsc: [false], inManagedObjectContext: managedObjectContext)
            
            // Try to get a comparison year
            var electionData:[[String:AnyObject]] = []
            electionData = Election.getPreviousElection(year: electionYear, sortOrder: ["year"], sortAsc: [false], inManagedObjectContext: managedObjectContext)
            if electionData.count == 0 {
                electionData = Election.getNextElection(year: electionYear, sortOrder: ["year"], sortAsc: [true], inManagedObjectContext: managedObjectContext)
            }
            
            // If we have a comparison years, get details
            if electionData.count > 0 {
                for election in electionData {
                    compareYear = (election["year"])! as! String
                    compareResults = []
                    compareResults = Detail.getBasicDetailsForConstituency(year: compareYear, constituency: onsid, sortOrder: ["votes"], sortAsc: [false], inManagedObjectContext: managedObjectContext)
                    if compareResults.count > 0 {
                        break
                    }
                }
            }
            
        }
        // Make the cell self size
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailTableViewCell
        
        // Configure the cell...
        cell.partyColor.backgroundColor = UIColor(hexString: (detailResults[indexPath.row]["party.colour"] as! String))
        cell.partyColor1.backgroundColor = UIColor(hexString: (detailResults[indexPath.row]["party.colour"] as! String))
        cell.party.text = (detailResults[indexPath.row]["party.name"] as! String)
        cell.fullName.text = (detailResults[indexPath.row]["fullName"] as! String)
        cell.votes.text = String.localizedStringWithFormat(" %d",detailResults[indexPath.row]["votes"] as! Int)
        cell.share.text = String.localizedStringWithFormat(" %.02f", (detailResults[indexPath.row]["share"] as! Double * 100))
        cell.change.text = String.localizedStringWithFormat(" %.02f", (detailResults[indexPath.row]["change"] as! Double * 100))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "sectionHeader")! as! DetailHeaderTableViewCell
        let constituencyResult = summaryResults.first
        if constituencyResult != nil {
            
            header.year.text = electionYear
            header.electorate.text = String.localizedStringWithFormat(" %d",(constituencyResult!["electorate"] as! Int))
            header.validVotes.text = String.localizedStringWithFormat(" %d",(constituencyResult!["validVotes"] as! Int))
            header.invalidVotes.text = String.localizedStringWithFormat(" %d",(constituencyResult!["invalidVotes"] as! Int))
            let turnoutPercent:Double = (Double((constituencyResult!["validVotes"] as! Int32) + (constituencyResult!["invalidVotes"] as! Int32)) / Double(constituencyResult!["electorate"] as! Int)) * 100.0
            header.turnoutPercent.text = String.localizedStringWithFormat(" %.02f",turnoutPercent)
            header.majorityVotes.text = String.localizedStringWithFormat(" %d",(constituencyResult!["majority"] as! Int))
            header.majorityPercent.text = String.localizedStringWithFormat(" %.02f",(constituencyResult!["majorityPercent"] as! Double))
            header.narrative.text = (constituencyResult!["narrative"] as! String)
            
            // Pie-chart for current results
            let pieChartView = PieChartView()
            pieChartView.frame = CGRect(x: 0, y: 5, width: view.frame.size.width/3, height: 100)
            
            for detail in detailResults {
                let partyColour = UIColor(hexString: detail["party.colour"] as! String)
                let segment : Segment = Segment(color: partyColour!, value: CGFloat(detail["votes"] as! Int))
                pieChartView.segments.append(segment)
            }
            
            header.addSubview(pieChartView)
            
            // Pie-chart for comparison results
            if compareResults.count > 0 {
                header.compareYear.text = compareYear
                let pieChartView2 = PieChartView()
                pieChartView2.frame = CGRect(x: (view.frame.size.width * 2)/3, y: 5, width: view.frame.size.width/3, height: 100)
                
                for detail in compareResults {
                    let partyColour = UIColor(hexString: detail["party.colour"] as! String)
                    let segment : Segment = Segment(color: partyColour!, value: CGFloat(detail["votes"] as! Int))
                    pieChartView2.segments.append(segment)
                }
                
                header.addSubview(pieChartView2)
            }
            
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableCell(withIdentifier: "sectionFooter")! as! DetailFooterTableViewCell
        
        // Get EU results for constituency if available
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        {
            let refResults = ConstituencyLocAuth.getBasicReferendumResults(onsid: onsid, sortOrder: ["wardsCon", "constituency.constituencyName"], sortAsc: [false, true], inManagedObjectContext: managedObjectContext)
            if refResults.count > 0 {
                
                footer.eurefheader.isHidden = false
                footer.electorateheader.isHidden = false
                footer.leaveheader.isHidden = false
                footer.leavepcheader.isHidden = false
                footer.locauthheader.isHidden = false
                footer.remainheader.isHidden = false
                footer.remainpcheader.isHidden = false
                footer.turnoutheader.isHidden = false
                
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
                footer.data2.text = ""
                
                var cnt = 0
                for refResult in refResults {
                    
                    var areaAndWards = (refResult["referendum.areaName"] as! String)
                    if (refResult["wardsCon"] as! Int) != 0 {
                        areaAndWards = areaAndWards + " (" + String.localizedStringWithFormat("%d",(refResult["wardsCon"] as! Int)) + "/" + String.localizedStringWithFormat("%d",(refResult["wardsLA"] as! Int)) + ")"
                    }
                    
                    if cnt == 0 {
                        footer.locauth1.text = areaAndWards
                        footer.electorate1.text = String.localizedStringWithFormat(" %d",(refResult["referendum.electorate"] as! Int))
                        footer.turnout1.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.turnoutPercent"] as! Double))
                        footer.remain1.text = String.localizedStringWithFormat(" %d",(refResult["referendum.remainVotes"] as! Int))
                        footer.remainpc1.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.remainPercent"] as! Double))
                        footer.leave1.text = String.localizedStringWithFormat(" %d",(refResult["referendum.leaveVotes"] as! Int))
                        footer.leavepc1.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.leavePercent"] as! Double))
                    }
                    if cnt == 1 {
                        footer.locauth2.text = areaAndWards
                        footer.electorate2.text = String.localizedStringWithFormat(" %d",(refResult["referendum.electorate"] as! Int))
                        footer.turnout2.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.turnoutPercent"] as! Double))
                        footer.remain2.text = String.localizedStringWithFormat(" %d",(refResult["referendum.remainVotes"] as! Int))
                        footer.remainpc2.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.remainPercent"] as! Double))
                        footer.leave2.text = String.localizedStringWithFormat(" %d",(refResult["referendum.leaveVotes"] as! Int))
                        footer.leavepc2.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.leavePercent"] as! Double))
                    }
                    if cnt == 2 {
                        footer.locauth3.text = areaAndWards
                        footer.electorate3.text = String.localizedStringWithFormat(" %d",(refResult["referendum.electorate"] as! Int))
                        footer.turnout3.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.turnoutPercent"] as! Double))
                        footer.remain3.text = String.localizedStringWithFormat(" %d",(refResult["referendum.remainVotes"] as! Int))
                        footer.remainpc3.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.remainPercent"] as! Double))
                        footer.leave3.text = String.localizedStringWithFormat(" %d",(refResult["referendum.leaveVotes"] as! Int))
                        footer.leavepc3.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.leavePercent"] as! Double))
                    }
                    if cnt == 3 {
                        footer.locauth4.text = areaAndWards
                        footer.electorate4.text = String.localizedStringWithFormat(" %d",(refResult["referendum.electorate"] as! Int))
                        footer.turnout4.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.turnoutPercent"] as! Double))
                        footer.remain4.text = String.localizedStringWithFormat(" %d",(refResult["referendum.remainVotes"] as! Int))
                        footer.remainpc4.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.remainPercent"] as! Double))
                        footer.leave4.text = String.localizedStringWithFormat(" %d",(refResult["referendum.leaveVotes"] as! Int))
                        footer.leavepc4.text = String.localizedStringWithFormat(" %.02f",(refResult["referendum.leavePercent"] as! Double))
                    }
                    
                    cnt += 1
                }
                
                footer.data2.text = "Contains National Statistics data © Crown copyright and database right 2015"
                
            } else {
                
            }
        }
        
        
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 140
    }
    
    
    @IBAction func unwindToDetailResults(sender: UIStoryboardSegue) {
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            var dc = segue.destination
            if let nc = dc as? UINavigationController {
                dc = nc.visibleViewController ?? dc
            }
            switch identifier {
            case "showWards" :
                if let vc = dc as? WardConTableViewController {
                    vc.onsid = onsid
                }
            default: break
            }
        }
        
    }
    
    
    
    
    
    
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

