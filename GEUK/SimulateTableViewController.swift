//
//  SimulateTableViewController.swift
//  GEUK_T1
//
//  Created by Mary Forde on 11/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import UIKit

protocol SimulateTableViewControllerDelegate: class {
    func reloadResults(year: String)
}
protocol ProgressViewDelegate: class {
    func updateProgress(progress: Float, progressText: String)
    func setSimulationEnded()
}
class SimulateTableViewController: UITableViewController, UITextFieldDelegate, YearRegionDelegate, ProgressViewDelegate {
    
    weak var delegate : SimulateTableViewControllerDelegate?
    
    private var basedOnElectionYear = "" {
        didSet {
            updateUI()
            tableView.reloadData()
        }
    }
    
    private var regionName = "UK Wide" {
        didSet {
            updateUI()
            tableView.reloadData()
        }
    }
    
    private var progress:Float = 0.0 {
        didSet {
            updateProgressBar()
        }
    }
    private var progressText:String = ""
    
    private var simRunEnded:Bool = false {
        didSet {
            simulationEnded()
        }
    }
    
    private var simulationName = ""
    private var simulationType = ""
    private var ukRegionName = "UK Wide"
    
    private var simParties = ["Con", "Lab", "LD", "UKIP", "Green", "SNP", "PC", "DUP", "SF", "SDLP", "UUP", "Alliance", "Other", "Chg%"]
    private var simStart:[String] = []
    private var simEnd:[String] = []
    private var simFromTo:[String] = []
    private var simConCount:[Int32] = []
    private var simColor:[String] = []
    private var simPercent:[[Double]] = []
    private var simEnabled:[[Bool]] = []
    
    // Save Rules Action
    @IBAction private func saveRules(_ sender: UIButton) {
        saveRules()
    }
    
    @IBAction private func runUniformSimulation(_ sender: UIButton) {
        simulationType = "Uniform"
        runSimulation()
    }
    
    @IBAction private func runProportionalSimulation(_ sender: UIButton) {
        simulationType = "Proportional"
        runSimulation()
    }
    
    // View loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        
        // Make the cell self size
        tableView.estimatedRowHeight = 30.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        updateUI()
        
    }
    
    internal func setElectionYear(year: String) {
        basedOnElectionYear = year
    }
    
    internal func setRegion(region: String) {
        regionName = region
    }
    
    // Set up the simulator data retrieving any previously stored rules
    private func updateUI() {
        
        if regionName == "UK Wide" {
            title = regionName + " Simulator based on " + basedOnElectionYear + " results"
        } else {
            title = regionName + " Override Simulator based on " + basedOnElectionYear + " results"
        }
        simulationName = basedOnElectionYear + " Sim"
        
        simStart = []
        simEnd = []
        simFromTo = []
        simConCount = []
        simColor = []
        simPercent = []
        simEnabled = []
        
        // Get Party Results and stored simulation rules
        var totalPercent:Double = 0.0
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        {
            let changePercent = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            let simEnable = [true,true,true,true,true,true,true,true,true,true,true,true,true,true]
            
            // Get the PartySummary details for each party and load to arrays and set up grid
            for party in simParties {
                simPercent.append(changePercent)
                simEnabled.append(simEnable)
                
                // Not the total row and not Other
                if party != "Chg%" && party != "Other" {
                    do {
                        var partyResults = PartySummary.getBasicPartyResult(year: basedOnElectionYear, region: regionName, party: party, inManagedObjectContext: managedObjectContext)
                        if (partyResults.count) > 0 {
                            simStart.append(String.localizedStringWithFormat(" %.02f", (partyResults.first?["votesPercent"] as! Double)))
                            simEnd.append(String.localizedStringWithFormat(" %.02f", (partyResults.first?["votesPercent"] as! Double)))
                            simColor.append((partyResults.first?["party.colour"] as! String))
                            totalPercent += (partyResults.first?["votesPercent"] as! Double)
                            partyResults = []
                        } else {
                            simStart.append(String.localizedStringWithFormat(" %.02f", 0.0))
                            simEnd.append(String.localizedStringWithFormat(" %.02f", 0.0))
                            if let theParty = Party.getParty(partyCode:party, inManagedObjectContext: managedObjectContext) {
                                simColor.append(theParty.colour!)
                            } else {
                                simColor.append("#DDDDDDFF")
                            }
                        }
                    }
                }
                
                if party == "Other" {
                    
                    do {
                        var partyResults = PartySummary.getBasicOtherPartyResult(year: basedOnElectionYear, region: regionName, parties: simParties, inManagedObjectContext: managedObjectContext)
                        if (partyResults.count) > 0 {
                            var otherCandidates = 0
                            var otherPercent = 0.0
                            for partyResult in partyResults {
                                otherCandidates += partyResult["candidates"] as! Int
                                otherPercent += partyResult["votesPercent"] as! Double
                            }
                            simStart.append(String.localizedStringWithFormat(" %.02f", otherPercent))
                            simEnd.append(String.localizedStringWithFormat(" %.02f", otherPercent))
                            simColor.append("#FFFFFFFF")
                            totalPercent += otherPercent
                            partyResults = []
                        } else {
                            simStart.append(String.localizedStringWithFormat(" %.02f", 0.0))
                            simEnd.append(String.localizedStringWithFormat(" %.02f", 0.0))
                            simColor.append("#DDDDDDFF")
                        }
                    }
                }
                
            }
            
            // Get the cross party constituency counts at regional or national level
            do {
                var simPartyCons = SimPartyConstituencies.getBasicSimPartyConsRegion(year: basedOnElectionYear, region: regionName, inManagedObjectContext: managedObjectContext)
                if simPartyCons.count > 0 {
                    for simPartyCon in simPartyCons {
                        simFromTo.append((simPartyCon["partyFrom"] as! String) + (simPartyCon["partyTo"] as! String))
                        simConCount.append(simPartyCon["constituencyCount"] as! Int32)
                    }
                    simPartyCons = []
                }
            }
            
            // Get the Simulation details
            do {
                var simResults = Simulation.getBasicRulesForSimulation(simulation: simulationName, region: regionName, inManagedObjectContext: managedObjectContext)
                for simulation in simResults {
                    if let indFrom = simParties.index(of: simulation["fromPartyCode"] as! String) {
                        if let indTo = simParties.index(of: simulation["toPartyCode"] as! String) {
                            let chgPercent = simulation["changePercent"] as! Double
                            simPercent[indFrom][indTo] = chgPercent
                            simPercent[indFrom][13] -= chgPercent
                            simPercent[13][indTo] += chgPercent
                            if simPercent[indFrom][indTo] != 0 {
                                simEnabled[indFrom][indTo] = true
                                simEnabled[indTo][indFrom] = false
                            }
                        }
                    }
                }
                simResults = []
            }
            
        }
        
        // Set the end percentage for each party
        var cnt = 0
        for party in simParties {
            if party != "Chg%" {
                let endPct = (simStart[cnt] as NSString).doubleValue + simPercent[cnt][13] + simPercent[13][cnt]
                simEnd[cnt] = String.localizedStringWithFormat(" %.02f", endPct)
            }
            cnt += 1
        }
        
        
        let  footer = tableView.dequeueReusableCell(withIdentifier: "sectionFooter")! as! SimulatorFooterTableViewCell
        if regionName == ukRegionName {
            footer.instructions.text = "Enter NATIONAL level percentages (+) to transfer from party in left column to the other parties"
            footer.message1.text = "Entire grid may be overridden at regional level"
            
            footer.message2.text = "To enter REGIONAL level overides, select Save Rules above and then select required Region from results list"
            footer.message3.text = "Would recommend Regional level overrides for Scotland, Wales and Northern Ireland"
        } else {
            footer.instructions.text = "Enter REGIONAL level percentages (+) to transfer from party in left column to the other parties"
            footer.message1.text = "Any entries will result in this entire grid replacing national grid for constituencies in region"
            
            footer.message2.text = "To enter NATIONAL level details, select Save Rules above and then select UK Wide as Region from results list "
            footer.message3.text = ""
        }
        
        footer.message4.text = "Simulation may take a few minutes to complete"
        footer.message5.text = "When complete, results are available under year " + basedOnElectionYear + " Sim"
        tableView.tableFooterView = footer
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return simParties.count
    }
    
    // Load up a party cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "simulatorCell", for: indexPath) as! SimulatorTableViewCell
        
        // Set this controller as delegaate for all text fields
        for field in (cell.contentView.subviews.first?.subviews)! {
            if let txtFld = field as? UITextField {
                txtFld.delegate = self
                txtFld.isEnabled = true
                txtFld.backgroundColor = UIColor.white
            }
        }
        
        // Configure the cell...
        cell.party.text = simParties[indexPath.row]
        
        // Normal party row
        if simParties[indexPath.row] != "Chg%" {
            cell.partyColor.backgroundColor = UIColor(hexString: simColor[indexPath.row])
            cell.startPercent.text = simStart[indexPath.row]
            cell.endPercent.text = simEnd[indexPath.row]
        } else {
            // Change results row - protact cells and change colour
            for field in (cell.contentView.subviews.first?.subviews)! {
                if let txtFld = field as? UITextField {
                    txtFld.isEnabled = false
                    txtFld.backgroundColor = UIColor(hexString: "#e1fff5ff")
                }
            }
        }
        
        // Load up the change percentages
        var cnt = 0
        for field in (cell.contentView.subviews.first?.subviews)! {
            if let txtFld = field as? UITextField {
                txtFld.text = (simPercent[indexPath.row][cnt] == 0 ? "" : String.localizedStringWithFormat("%g",simPercent[indexPath.row][cnt]))
                let loc = simFromTo.index(of: (simParties[indexPath.row] + simParties[cnt]))
                if cnt == indexPath.row || (loc != nil && simConCount[loc!] == 0) || (simEnabled[indexPath.row][cnt] == false) {
                    if simParties[indexPath.row] != "Chg%" {
                        txtFld.backgroundColor = UIColor.lightGray
                        txtFld.isEnabled = false
                        simEnabled[indexPath.row][cnt] = false
                    }
                }
                cnt += 1
            }
        }
        
        cell.change14.backgroundColor = UIColor(hexString: "#e1fff5ff")
        cell.change14.isEnabled = false
        
        return cell
    }
    
    // Set up the header details
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "sectionHeader")! as! SimulatorHeaderTableViewCell
        
        // Configure the cell...
        header.party.text = ""
        header.startPercent.text = "Start %"
        header.endPercent.text = "End %"
        
        header.party01.text = simParties[0]
        header.party02.text = simParties[1]
        header.party03.text = simParties[2]
        header.party04.text = simParties[3]
        header.party05.text = simParties[4]
        header.party06.text = simParties[5]
        header.party07.text = simParties[6]
        header.party08.text = simParties[7]
        header.party09.text = simParties[8]
        header.party10.text = simParties[9]
        header.party11.text = simParties[10]
        header.party12.text = simParties[11]
        header.party13.text = simParties[12]
        header.party14.text = simParties[13]
        header.partyColor01.backgroundColor = UIColor(hexString: simColor[0])
        header.partyColor02.backgroundColor = UIColor(hexString: simColor[1])
        header.partyColor03.backgroundColor = UIColor(hexString: simColor[2])
        header.partyColor04.backgroundColor = UIColor(hexString: simColor[3])
        header.partyColor05.backgroundColor = UIColor(hexString: simColor[4])
        header.partyColor06.backgroundColor = UIColor(hexString: simColor[5])
        header.partyColor07.backgroundColor = UIColor(hexString: simColor[6])
        header.partyColor08.backgroundColor = UIColor(hexString: simColor[7])
        header.partyColor09.backgroundColor = UIColor(hexString: simColor[8])
        header.partyColor10.backgroundColor = UIColor(hexString: simColor[9])
        header.partyColor11.backgroundColor = UIColor(hexString: simColor[10])
        header.partyColor11.backgroundColor = UIColor(hexString: simColor[10])
        header.partyColor12.backgroundColor = UIColor(hexString: simColor[11])
        header.partyColor13.backgroundColor = UIColor(hexString: simColor[12])
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    // Only allow digits and decimal point to be entered in text cells
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var result = true
        let text = textField.text!
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        
        if string.characters.count > 0 {
            let invalidChars = NSCharacterSet(charactersIn: "0123456789.").inverted
            let charsAreValid = string.rangeOfCharacter(from: invalidChars) == nil
            let scanner = Scanner(string: newText)
            result = charsAreValid && scanner.scanDecimal(nil) && scanner.isAtEnd
        }
        return result
    }
    
    // Recalculate totals and update grid
    func textFieldDidEndEditing(_ textField: UITextField) {
        storeValues()
    }
    
    // Save rules to table
    private func saveRules() {
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        {
            // Make sure nothing is outstanding
            managedObjectContext.reset()
            
            // Recalculate and update grid
            storeValues()
            
            // Remove all the existing rules for simulation before reloading
            Simulation.removeData(year: simulationName, regionName: regionName, inManagedObjectContext: managedObjectContext)
            
            // Add back all the rules on screen
            var cntFrom = 0
            for fromParty in simParties {
                if fromParty != "Chg%" {
                    var cntTo = 0
                    for toParty in simParties {
                        if toParty != "Chg%" {
                            if simPercent[cntFrom][cntTo] != 0.0 {
                                let item = (year: simulationName, regionName: regionName, fromPartyCode: fromParty, toPartyCode: toParty, changePercent: (simPercent[cntFrom][cntTo]))
                                _ = Simulation.loadSimulation(item: item, inManagedObjectContext: managedObjectContext)
                            }
                        }
                        cntTo += 1
                    }
                }
                cntFrom += 1
            }
            do {
                try managedObjectContext.save()
            } catch {
            }
        }
    }
    
    // Recalculate totals and update grid
    private func storeValues() {
        
        simPercent[13] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        var cnt = 0
        for cell in tableView.visibleCells {
            
            if let detailCell = cell as? SimulatorTableViewCell {
                if detailCell.party.text != "Chg%" {
                    
                    // Load up the change percentages from the display
                    var col = 0
                    for field in (cell.contentView.subviews.first?.subviews)! {
                        if let txtFld = field as? UITextField {
                            simPercent[cnt][col] = (txtFld.text != "" ? ((txtFld.text!) as NSString).doubleValue : 0.0)
                            if simPercent[cnt][col] != 0.0 {
                                simEnabled[cnt][col] = true
                                simEnabled[col][cnt] = false
                            } else {
                                if simEnabled[cnt][col] == true {
                                    simEnabled[col][cnt] = true
                                }
                            }
                            col += 1
                        }
                    }
                    
                    // Update the total column
                    simPercent[cnt][13] = 0
                    for i in 0...12 {
                        simPercent[cnt][13] += simPercent[cnt][i]
                    }
                    simPercent[cnt][13] = simPercent[cnt][13] * -1
                    
                    // Update the total row
                    detailCell.change14.text = (simPercent[cnt][13] == 0 ? "" :String.localizedStringWithFormat("%g",simPercent[cnt][13]))
                    
                    for i in 0...12 {
                        simPercent[13][i] = simPercent[13][i] + simPercent[cnt][i]
                    }
                    
                } else {
                    
                    // Load up the total row change percentages back to display
                    var col = 0
                    for field in (cell.contentView.subviews.first?.subviews)! {
                        if let txtFld = field as? UITextField {
                            txtFld.text = (simPercent[13][col] == 0.0 ? "" :String.localizedStringWithFormat("%g",simPercent[13][col]))
                            col += 1
                        }
                    }
                }
                cnt += 1
            }
            
        }
        
        // Update the End percentages
        cnt = 0
        for cell in tableView.visibleCells {
            
            if let detailCell = cell as? SimulatorTableViewCell {
                if detailCell.party.text != "Chg%" {
                    let endPct = ((detailCell.startPercent.text!) as NSString).doubleValue + simPercent[cnt][13] + simPercent[13][cnt]
                    detailCell.endPercent.text = String.localizedStringWithFormat(" %.02f",endPct)
                }
            }
            cnt += 1
        }
        
        // Enabled / Disable cells
        cnt = 0
        for cell in tableView.visibleCells {
            
            if let detailCell = cell as? SimulatorTableViewCell {
                if detailCell.party.text != "Chg%" {
                    // Load up the change percentages from the display
                    var col = 0
                    for field in (cell.contentView.subviews.first?.subviews)! {
                        if let txtFld = field as? UITextField {
                            if col != 13 {
                                if simEnabled[cnt][col] == false {
                                    txtFld.backgroundColor = UIColor.lightGray
                                    txtFld.isEnabled = false
                                } else {
                                    txtFld.backgroundColor = UIColor.white
                                    txtFld.isEnabled = true
                                }
                            }
                            col += 1
                        }
                    }
                }
            }
            cnt += 1
        }
        
    }
    
    // Run the simulation
    private func runSimulation() {
        saveRules()
        
        if let footer = tableView.tableFooterView as? SimulatorFooterTableViewCell {
            DispatchQueue.main.async {
                footer.saveRules.isEnabled = false
                footer.runUniform.isEnabled = false
                footer.runProportional.isEnabled = false
                footer.setNeedsDisplay()
            }
        }
        
        // if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.performBackgroundTask {
            (context) in
            var simulator = Simulator()
            simulator.simulationType = self.simulationType
            simulator.simulationName = self.simulationName
            simulator.basedOnElectionYear = self.basedOnElectionYear
            simulator.managedObjectContext = context
            simulator.runSimulation(simulator: self)
            do {
                try context.save()
            } catch {
            }
            simulator = Simulator()
        }
        
    }

    internal func setSimulationEnded() {
        self.simRunEnded = true
    }
    
    private func simulationEnded() {
        self.delegate?.reloadResults(year: self.simulationName)
        if let footer = tableView.tableFooterView as? SimulatorFooterTableViewCell {
            DispatchQueue.main.async {
                footer.saveRules.isEnabled = true
                footer.runUniform.isEnabled = true
                footer.runProportional.isEnabled = true
                footer.setNeedsDisplay()
            }
        }
    }
    
    internal func updateProgress(progress: Float, progressText: String) {
        self.progressText = progressText
        self.progress = progress
    }
    
    private func updateProgressBar() {
        if let footer = tableView.tableFooterView as? SimulatorFooterTableViewCell {
            DispatchQueue.main.async {
                footer.message7.text = self.progressText
                footer.progressView.setProgress(self.progress, animated: true)
                footer.setNeedsDisplay()
            }
        }
    }
    
    
}
