//
//  Simulator.swift
//  GEUK_T1
//
//  Created by Mary Forde on 19/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

public class Simulator {
    
    public var simulationType = ""
    public var simulationName = ""
    public var basedOnElectionYear = ""
    public var managedObjectContext: NSManagedObjectContext? = nil
    
    private var parties:[String] = []
    private var seats:[Int32] = []
    private var partyVotes:[Int32] = []
    private var lastPartyIdx = 0
    
    private var regParties:[String] = []
    private var regSeats:[Int32] = []
    private var regPartyVotes:[Int32] = []
    private var regTotalVotes = 0
    private var lastRegPartyIdx = 0
    
    private var ukRegionName = "UK Wide"
    private var simParties = ["Con", "Lab", "LD", "UKIP", "Green", "SNP", "PC", "DUP", "SF", "SDLP", "UUP", "Alliance", "Other", "Chg%"]
    private var simFromTo:[String] = []
    private var simConCount:[Int32] = []
    private var simElectorate:[Int32] = []
    private var simPartyFromVotes: [Int32] = []
    private var simCandidates:[Int32] = []
    private var simStart:[Double] = []
    
    private var constituencies: [String] = []
    private var validVotes: [Int32] = []
    private var conCount = 0
    private var electorate = 0
    private var partyFromVotes = 0
    
    // Rules - From/To parties and change percentages to use
    private var fromTo: [String] = []
    private var changePercent: [Double] = []

    private var progressText = ""
    
    var Timestamp: String {
        return "\(NSDate().timeIntervalSince1970 * 1000)"
    }
    
    // Run the simulation
    func runSimulation(simulator: SimulateTableViewController) {
        
        progressText = "Deleting old simulation data"
        DispatchQueue.main.async {[] in
            simulator.updateProgress(progress: 0.0, progressText: self.progressText)
        }
        
        // Delete existing records for simulation
        deleteSimulation()
        
        progressText = "Copying election data to simulation"
        DispatchQueue.main.async {[] in
            simulator.updateProgress(progress: 0.05, progressText: self.progressText)
        }
        
        // Create duplicates of the based on election year data
        duplicateElectionData()
        
        progressText = "Performing simulation by region/constituency"
        DispatchQueue.main.async {[] in
            simulator.updateProgress(progress: 0.35, progressText: self.progressText)
        }
        
        // Apply simulation rules
        do {
            
            // Get the constituency summaries
            var con = Summary.getConstituencyVotes(year: basedOnElectionYear, inManagedObjectContext: managedObjectContext!)
            constituencies = con.constituencies
            validVotes = con.validVotes
            con = ([],[])
            
            // Get the national simulation rules and election details
            var rule = Simulation.getRulesBasic(year: simulationName, region: ukRegionName, inManagedObjectContext: managedObjectContext!)
            var elect = Election.getElection(year: basedOnElectionYear, inManagedObjectContext: managedObjectContext!)
            let nationalValidVotes = elect.first?.validVotes
            let nationalCount = constituencies.count
            let nationalFromTo = rule.fromTo
            let nationalChangePercent = rule.changePercent
            rule = ([],[])
            elect = []
            
            // Get the party summaries for the parties we can transfer from for the based on election
            var nationalSimCandidates:[Int32] = []
            var nationalSimStart:[Double] = []
            for cnt in 0...simParties.count - 1 {
                var partyResults = PartySummary.getPartyResult(year: basedOnElectionYear, region: ukRegionName, party: simParties[cnt], inManagedObjectContext: managedObjectContext!)
                if partyResults.count > 0 {
                    nationalSimCandidates.append(partyResults.first!.candidates)
                    nationalSimStart.append((partyResults.first?.votesPercent)!)
                } else {
                    nationalSimCandidates.append(0)
                    nationalSimStart.append(0.0)
                }
                partyResults = []
            }
            
            // Get the cross party constituency counts at national level
            var nationalSimFromTo: [String] = []
            var nationalSimConCount: [Int32] = []
            var nationalSimElectorate: [Int32] = []
            var nationalSimPartyFromVotes: [Int32] = []
            do {
                var simPartyCons = SimPartyConstituencies.getSimPartyConsRegion(year: basedOnElectionYear, region: ukRegionName, inManagedObjectContext: managedObjectContext!)
                if simPartyCons.count > 0 {
                    for simPartyCon in simPartyCons {
                        nationalSimFromTo.append(simPartyCon.partyFrom! + simPartyCon.partyTo!)
                        nationalSimConCount.append(simPartyCon.constituencyCount)
                        nationalSimElectorate.append(simPartyCon.electorate)
                        nationalSimPartyFromVotes.append(simPartyCon.partyFromVotes)
                    }
                }
                simPartyCons = []
            }

            DispatchQueue.main.async {[] in
                simulator.updateProgress(progress: 0.4, progressText: self.progressText)
            }
            
            // Main Loop - Go through the constituency results
            var detailResults = Detail.getBasicDetailsForElection(year:simulationName, sortOrder:["constituency.regionName", "constituency.constituencyName"], sortAsc:[true, true], inManagedObjectContext: managedObjectContext!)
            if detailResults.count > 0 {
                
                var countCon = 0
                var lastRegion = ""
                var lastConstituency = ""
                var lastConstituencyName = ""
                var constitParties: [String] = []
                var actualPercent: [Double] = []
                var transPercent: [Double] = []
                
                // For each candidate level result
                for detailResult in detailResults {
                    
                    // Change of constituency
                    if (detailResult["onsid"] as! String) != lastConstituency && lastConstituency != "" {
                        // Perform transfers for a constituency
                        performTransfers(constituency: lastConstituency, constitParties: constitParties, actualPercent: actualPercent, transPercent: transPercent, inManagedObjectContext: managedObjectContext!)
                        // Clear last constituency totals
                        constitParties = []
                        transPercent = []
                        actualPercent = []
                        countCon = countCon + 1
                        let complete:Float = 0.40 + (0.60 * Float(countCon)/650.0)
                        progressText = "\(countCon)/650 \(lastRegion)/\(lastConstituencyName)"
                        DispatchQueue.main.async {[] in
                            simulator.updateProgress(progress: complete, progressText: self.progressText)
                        }
                    }
                    
                    // Change of region, update last region party summeries
                    if (detailResult["constituency.regionName"] as! String) != lastRegion && lastRegion != "" {
                        // Update the party totals for region
                        if regParties.count > 0 {
                            for cnt in 0...regParties.count - 1 {
                                let votesPercent = (Double(regPartyVotes[cnt]) / Double(regTotalVotes)) * 100
                                PartySummary.updateResults(year: simulationName, regionName: lastRegion, partyCode: regParties[cnt], seats: regSeats[cnt], votes: regPartyVotes[cnt], votesPercent: votesPercent, inManagedObjectContext: managedObjectContext!)
                                do {
                                    try managedObjectContext?.save()
                                } catch {
                                    
                                }
                            }
                        }
                        // Clear region totals
                        regParties = []
                        regPartyVotes = []
                        regSeats = []
                        regTotalVotes = 0
                        lastRegPartyIdx = 0
                    }
                    
                    // Change of region or first region
                    if (detailResult["constituency.regionName"] as! String) != lastRegion || lastRegion == "" {
                        
                        // Get the regional simulation rules
                        var rule = Simulation.getRulesBasic(year: simulationName, region: (detailResult["constituency.regionName"] as! String), inManagedObjectContext: managedObjectContext!)
                        let regionalFromTo = rule.fromTo
                        let regionalChangePercent = rule.changePercent
                        rule = ([],[])
                        
                        // No regional rules, use national rules else use regional rules
                        if regionalFromTo.count == 0 {
                            fromTo = nationalFromTo
                            changePercent = nationalChangePercent
                            simCandidates = nationalSimCandidates
                            simStart = nationalSimStart
                            simFromTo = nationalSimFromTo
                            simConCount = nationalSimConCount
                            simElectorate = nationalSimElectorate
                            simPartyFromVotes = nationalSimPartyFromVotes
                            conCount = nationalCount
                            electorate = Int(nationalValidVotes!)
                        } else {
                            // Use regional rules
                            fromTo = regionalFromTo
                            changePercent = regionalChangePercent
                            
                            conCount = Int(Constituency.getConCountInRegion(region: (detailResult["constituency.regionName"] as! String), inManagedObjectContext: managedObjectContext!))
                            electorate = Int(Summary.getRegionVotes(year: basedOnElectionYear, region: (detailResult["constituency.regionName"] as! String), inManagedObjectContext: managedObjectContext!))
                            
                            // Get the party summaries
                            simCandidates = []
                            simStart = []
                            for cnt in 0...simParties.count - 1 {
                                var partyResults = PartySummary.getPartyResult(year: basedOnElectionYear, region: (detailResult["constituency.regionName"] as! String), party: simParties[cnt], inManagedObjectContext: managedObjectContext!)
                                if partyResults.count > 0 {
                                    simCandidates.append(partyResults.first!.candidates)
                                    simStart.append((partyResults.first?.votesPercent)!)
                                } else {
                                    simCandidates.append(0)
                                    simStart.append(0.0)
                                }
                                partyResults = []
                            }
                            // Get the cross party constituency counts at regional level
                            simFromTo = []
                            simConCount = []
                            simElectorate = []
                            simPartyFromVotes = []
                            do {
                                var simPartyCons = SimPartyConstituencies.getSimPartyConsRegion(year: basedOnElectionYear, region: (detailResult["constituency.regionName"] as! String), inManagedObjectContext: managedObjectContext!)
                                if simPartyCons.count > 0 {
                                    for simPartyCon in simPartyCons {
                                        simFromTo.append(simPartyCon.partyFrom! + simPartyCon.partyTo!)
                                        simConCount.append(simPartyCon.constituencyCount)
                                        simElectorate.append(simPartyCon.electorate)
                                        simPartyFromVotes.append(simPartyCon.partyFromVotes)
                                    }
                                }
                                simPartyCons = []
                            }
                        }
                    }
                    
                    // For each result, store party and percentage
                    constitParties.append(detailResult["partyCode"] as! String)
                    actualPercent.append(detailResult["share"] as! Double * 100)
                    transPercent.append(0.0)
                    
                    // Store last constituency and region
                    lastConstituency = detailResult["onsid"] as! String
                    lastConstituencyName = detailResult["constituency.constituencyName"] as! String
                    lastRegion = (detailResult["constituency.regionName"] as! String)
                }
                
                // Perform transfers for last constituency
                performTransfers(constituency: lastConstituency, constitParties: constitParties, actualPercent: actualPercent, transPercent: transPercent, inManagedObjectContext: managedObjectContext!)
                countCon = countCon + 1
                let complete:Float = 0.40 + (0.60 * Float(countCon)/650.0)
                progressText = "\(countCon)/650 \(lastRegion)/\(lastConstituencyName)"
                DispatchQueue.main.async {[] in
                    simulator.updateProgress(progress: complete, progressText: self.progressText)
                }

                // Update the party totals for region
                if regParties.count > 0 {
                    for cnt in 0...regParties.count - 1 {
                        let votesPercent = (Double(regPartyVotes[cnt]) / Double(regTotalVotes)) * 100
                        PartySummary.updateResults(year: simulationName, regionName: lastRegion, partyCode: regParties[cnt], seats: regSeats[cnt], votes: regPartyVotes[cnt], votesPercent: votesPercent, inManagedObjectContext: managedObjectContext!)
                        do {
                            try managedObjectContext?.save()
                        } catch {
                            
                        }
                    }
                }
                
            }
            detailResults = [[:]]
            
            // Update the party totals
            if parties.count > 0 {
                for cnt in 0...parties.count - 1 {
                    let votesPercent = (Double(partyVotes[cnt]) / Double(nationalValidVotes!)) * 100
                    PartySummary.updateResults(year: simulationName, regionName: ukRegionName, partyCode: parties[cnt], seats: seats[cnt], votes: partyVotes[cnt], votesPercent: votesPercent, inManagedObjectContext: managedObjectContext!)
                    do {
                        try managedObjectContext?.save()
                    } catch {
                        
                    }
                }
            }
            
        }

        do {
            try managedObjectContext?.save()
        } catch {
        }

        DispatchQueue.main.async {[] in
            simulator.setSimulationEnded()
        }

    }
    
    // Delete existing simulation records
    private func deleteSimulation() {
        
        Detail.removeElectionData(election: simulationName, inManagedObjectContext: managedObjectContext!)
        do {
            try managedObjectContext?.save()
        } catch {
            
        }
        Summary.removeElectionData(election: simulationName, inManagedObjectContext: managedObjectContext!)
        do {
            try managedObjectContext?.save()
        } catch {
            
        }
        PartySummary.removeElectionData(election: simulationName, inManagedObjectContext: managedObjectContext!)
        do {
            try managedObjectContext?.save()
        } catch {
            
        }
        Election.removeElectionData(election: simulationName, inManagedObjectContext: managedObjectContext!)
        do {
            try managedObjectContext?.save()
        } catch {
            
        }
        
    }
    
    // Duplicate election data
    private func duplicateElectionData() {
        
        Summary.setupSimulationData(election: simulationName, basedOnYear: basedOnElectionYear, inManagedObjectContext: managedObjectContext!)
        do {
            try managedObjectContext?.save()
        } catch {
            
        }
        
        Detail.setupSimulationData(election: simulationName, basedOnYear: basedOnElectionYear, inManagedObjectContext: managedObjectContext!)
        do {
            try managedObjectContext?.save()
        } catch {
            
        }
        
        PartySummary.setupSimulationData(election: simulationName, basedOnYear: basedOnElectionYear, inManagedObjectContext: managedObjectContext!)
        do {
            try managedObjectContext?.save()
        } catch {
            
        }
        
        Election.setupSimulationData(election: simulationName, basedOnYear: basedOnElectionYear, inManagedObjectContext: managedObjectContext!)
        do {
            try managedObjectContext?.save()
        } catch {
            
        }
        
    }
    
    // Perform transfers for the constituency
    private func performTransfers(constituency: String, constitParties: [String], actualPercent:  [Double], transPercent: [Double], inManagedObjectContext context: NSManagedObjectContext) {
        
        var trnsPercent = transPercent
        
        // Go through all the parties in the constituency and count Other parties
        var otherCnt = 0
        for constitFromParty in constitParties {
            if simParties.index(of: constitFromParty) == nil {
                otherCnt += 1
            }
        }
        
        // Go through all the parties in the constituency
        var conFromTo:[String] = []
        var conAdjPercent:[Double] = []
        var fromPty = 0
        for constitFromParty in constitParties {
            
            // Match up against the other parties in the constituency
            var toPty = 0
            for constitToParty in constitParties {
                
                // Only need to attempt transfer if parties are different
                if constitFromParty != constitToParty {
                    
                    // Are the From/To parties both main parties that allow transfers ?
                    var ruleLoc = fromTo.index(of: constitFromParty + constitToParty)
                    // No, can only one of the parties be classified as other ? Not both
                    if ruleLoc == nil {
                        let ind1 = simParties.index(of: constitFromParty)
                        let ind2 = simParties.index(of: constitToParty)
                        if ind1 != nil || ind2 != nil {
                            let partyFromTo = (ind1 == nil ? "Other":constitFromParty) + (ind2 == nil ? "Other":constitToParty)
                            ruleLoc = fromTo.index(of: partyFromTo)
                        }
                    }
                    
                    // Got a transfer rule - either for both parties or one party and Other
                    if ruleLoc != nil {
                        
                        // Set the adjustment percentage
                        var adjChgPercent = changePercent[ruleLoc!]
                        
                        // Location of the From/To parties in the simulation cross party details arrays
                        var fromToLoc = simFromTo.index(of: constitFromParty + constitToParty)
                        if fromToLoc == nil {
                            let ind1 = simParties.index(of: constitFromParty)
                            let ind2 = simParties.index(of: constitToParty)
                            let partyFromTo = (ind1 == nil ? "Other":constitFromParty) + (ind2 == nil ? "Other":constitToParty)
                            fromToLoc = simFromTo.index(of: partyFromTo)
                        }
                        
                        // If the number of common constiuencies is less than the total constituencies, need to scale up the percentage
                        if Int(simConCount[fromToLoc!]) < conCount {
                            adjChgPercent = adjChgPercent * Double(electorate) / Double(simElectorate[fromToLoc!])
                        }
                        
                        if simulationType == "Proportional" {
                            
                            // Location of From party in the parties to process array
                            var fromLoc = simParties.index(of: constitFromParty)
                            if fromLoc == nil {
                                fromLoc = simParties.index(of: "Other")
                            }
                            
                            if simStart[fromLoc!] != 0.0 {
                                // Need to adjust by this constituency's percent against the start percent
                                if Int(simCandidates[fromLoc!]) < conCount {
                                    let startPercent = (Double(simPartyFromVotes[fromToLoc!]) / Double(simElectorate[fromToLoc!])) * 100.0
                                    adjChgPercent = adjChgPercent * (actualPercent[fromPty] / startPercent)
                                } else {
                                    adjChgPercent = adjChgPercent * (actualPercent[fromPty] / simStart[fromLoc!])
                                }
                            }
                        }
                        
                        // Store the cross party percent
                        conFromTo.append(constitFromParty + constitToParty)
                        conAdjPercent.append(adjChgPercent)
                        
                        // If either from or to party is Other, split transfer percentage by the number of other parties
                        if simParties.index(of: constitFromParty) == nil || simParties.index(of: constitToParty) == nil {
                            adjChgPercent = adjChgPercent / Double(otherCnt)
                        }
                        
                        // Add to To party transfer percent and subtract from From party
                        trnsPercent[fromPty] -= adjChgPercent
                        trnsPercent[toPty] += adjChgPercent
                    }
                }
                toPty += 1
            }
            fromPty += 1
        }
        
        // Check if any transfers are greater than the vote that was obtained by the party in constituency and adjust transfer percent
        fromPty = 0
        for constitFromParty in constitParties {
            
            // Party has a transfer of votes out
            if trnsPercent[fromPty] < 0.0 {
                let totalTransfer = trnsPercent[fromPty] * -1
                
                // Percentage to transfer is greater than party achieved in the election
                if totalTransfer > actualPercent[fromPty] {
                    
                    // Get the other parties in the constituency
                    var toPty = 0
                    for constitToParty in constitParties {
                        // Different party
                        if constitFromParty != constitToParty {
                            // Is there a stored adjustment percent
                            let loc = conFromTo.index(of: constitFromParty + constitToParty)
                            
                            // Got a transfer percentage
                            var adjChgPercent = 0.0
                            if loc != nil {
                                
                                adjChgPercent = conAdjPercent[loc!]
                                
                                // Scale down by proportion of actual percent to the requested transfer
                                var adjPct = adjChgPercent * actualPercent[fromPty] / totalTransfer
                                
                                // Add the unscaled transfer percentage back to the from party
                                trnsPercent[fromPty] += adjChgPercent
                                // If the To party is Other - split by number of others in constituency
                                if simParties.index(of: constitToParty) == nil {
                                    adjChgPercent = adjChgPercent / Double(otherCnt)
                                }
                                // Remove from the To party
                                trnsPercent[toPty] -= adjChgPercent
                                
                                // Subtract the new scaled down transfer percent from the From party
                                trnsPercent[fromPty] -= adjPct
                                // If the To party is Other - split by number of others in constituency
                                if simParties.index(of: constitToParty) == nil {
                                    adjPct = adjChgPercent / Double(otherCnt)
                                }
                                // Add to the To party
                                trnsPercent[toPty] += adjPct
                            }
                        }
                        toPty += 1
                    }
                }
            }
            fromPty += 1
        }
        
        // Update the results for each candidate in the constituency
        let validVote = validVotes[constituencies.index(of: constituency)!]
        if constitParties.count > 0 {
            for cnt in 0...constitParties.count - 1 {
                if trnsPercent[cnt] != 0.0 {
                    let transferVotes = Int(round((Double(validVote) * trnsPercent[cnt]) / 100))
                    let change = (Double(transferVotes) / Double(validVote))
                    Detail.transferVotes(year: simulationName, onsid: constituency, partyCode: constitParties[cnt], transferVotes: Int32(transferVotes), change: change, inManagedObjectContext: context)
                    do {
                        try context.save()
                    } catch {
                        
                    }
                }
            }
        }
        
        // Get the detail results for the constituency and update the constituency summary
        var detailResults = Detail.getDetailsForConstituency(year:simulationName, constituency: constituency, sortOrder:["votes"], sortAsc:[false], inManagedObjectContext: managedObjectContext!)
        
        var partyCode = ""
        var runnerUpCode = ""
        var firstName = ""
        var surname = ""
        var firstVotes:Int32 = 0
        var majorityVotes:Int32 = 0
        
        // Go through the constituency details in reverse votes order
        for detail in detailResults {
            
            // Find party in the region totals
            var regPartyIdx = regParties.index(of: detail.partyCode!)
            // Not already there, add in new party details
            if regPartyIdx == nil {
                regParties.append(detail.partyCode!)
                regSeats.append(0)
                regPartyVotes.append(0)
                lastRegPartyIdx += 1
                regPartyIdx = regParties.index(of: detail.partyCode!)
            }
            
            // Find party in the national totals
            var partyIdx = parties.index(of: detail.partyCode!)
            // Not already there, add in new party details
            if partyIdx == nil {
                parties.append(detail.partyCode!)
                seats.append(0)
                partyVotes.append(0)
                lastPartyIdx += 1
                partyIdx = parties.index(of: detail.partyCode!)
            }
            
            // Have found winning party but not runner-up, set the runner-up details
            if partyCode != "" && runnerUpCode == "" {
                runnerUpCode = detail.partyCode!
                majorityVotes = firstVotes - detail.votes
            }
            
            // Not found winning party, set current party as winner
            if partyCode == "" {
                partyCode = detail.partyCode!
                firstName = detail.firstName!
                surname = detail.surname!
                firstVotes = detail.votes
                seats[partyIdx!] += 1
                regSeats[regPartyIdx!] += 1
            }
            
            // Update totals for region and nationally
            partyVotes[partyIdx!] += detail.votes
            regPartyVotes[regPartyIdx!] += detail.votes
            regTotalVotes += Int(detail.votes)
        }
        detailResults = []
        
        // Update the constituency summary
        Summary.updateResults(year: simulationName, onsid: constituency, partyCode: partyCode, firstName: firstName, surname: surname, majority: majorityVotes, runnerUp: runnerUpCode, inManagedObjectContext: context)
        do {
            try context.save()
        } catch {
            
        }
        
    }
    
    
}
