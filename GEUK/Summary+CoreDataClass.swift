//
//  Summary+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 24/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(Summary)
public class Summary: NSManagedObject {
 
    // Return all records for an election year
    class func getSummariesForElection(year:String, inManagedObjectContext context: NSManagedObjectContext) -> [Summary] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.predicate = NSPredicate(format: "year = %@", year)
        if let summaries = (try? context.fetch(request)) as? [Summary] {
            return summaries
        }  else {
            return []
        }
    }
    
    // Return record for a constituency - selected fields
    class func getBasicSummaryForElectionConstituency(year:String, onsid:String, inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.propertiesToFetch = ["electorate","validVotes","invalidVotes","majority","majorityPercent","narrative"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and onsid = %@", year, onsid)
        if let summary = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return summary
        }  else {
            return [[:]]
        }
    }
    
    // Return latest results for a constituency - selected fields
    class func getLatestResultForConstituency(onsid:String, inManagedObjectContext context: NSManagedObjectContext) -> [String:AnyObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.propertiesToFetch = ["fullName","partyCode","party.colour"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "onsid = %@ and NOT(year contains[c] %@)", onsid, "Sim")
        request.sortDescriptors = [NSSortDescriptor(key:"year", ascending: false)]

        if let summary = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return summary.first!
        }  else {
            return [:]
        }
    }

    // Return record for a constituency
    class func getSummaryForElectionConstituency(year:String, onsid:String, inManagedObjectContext context: NSManagedObjectContext) -> [Summary] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.predicate = NSPredicate(format: "year = %@ and onsid = %@", year, onsid)
        if let summary = (try? context.fetch(request)) as? [Summary] {
            return summary
        }  else {
            return []
        }
    }

    // Return all records for an election year
    class func getSummariesForElectionRegion(year:String, region:String, sortColumns:[String],searchText:String, inManagedObjectContext context: NSManagedObjectContext) -> [Summary] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        
        // Set sort order
        var sortDescriptors:[NSSortDescriptor] = []
        for sortColumn in sortColumns {
            switch sortColumn {
            case "Region":
                sortDescriptors.append(NSSortDescriptor(key: "constituency.regionName", ascending: true))
            case "Constituency":
                sortDescriptors.append(NSSortDescriptor(key: "constituency.constituencyName", ascending: true))
            case "Winning Party":
                sortDescriptors.append(NSSortDescriptor(key: "party.name", ascending: true))
            case "Elected MP":
                sortDescriptors.append(NSSortDescriptor(key: "surname", ascending: true))
                sortDescriptors.append(NSSortDescriptor(key: "firstName", ascending: true))
            case "Majority %":
                sortDescriptors.append(NSSortDescriptor(key: "majorityPercent", ascending: true))
            case "Previous Party":
                sortDescriptors.append(NSSortDescriptor(key: "prevParty.name", ascending: true))
            case "Runner-up Party":
                sortDescriptors.append(NSSortDescriptor(key: "runnerupparty.name", ascending: true))
            case "Party Changed":
                sortDescriptors.append(NSSortDescriptor(key: "partyChanged", ascending: false))
            default:
                break
            }
        }
        
        request.sortDescriptors = sortDescriptors

        // Filter results by search and region
        if searchText != "" {
            if region == "UK Wide" {
                request.predicate = NSPredicate(format: "year = %@ and (constituency.constituencyName contains[c] %@ or fullName contains[c] %@ or party.name contains[c] %@ or constituency.regionName contains[c] %@ or (ANY detailResults.fullName =[c] %@)) " , year, searchText, searchText, searchText, searchText, searchText, searchText, searchText)
            } else {
                request.predicate = NSPredicate(format: "year = %@ and constituency.regionName = %@ and (constituency.constituencyName contains[c] %@ or fullName contains[c] %@ or party.name contains[c] %@ or constituency.regionName contains[c] %@ (or ANY detailResults.fullName =[c] %@)) " , year, region, searchText, searchText, searchText, searchText, searchText, searchText)
            }
        } else {
            if region == "UK Wide" {
                request.predicate = NSPredicate(format: "year = %@" , year)
            } else {
                request.predicate = NSPredicate(format: "year = %@ and constituency.regionName = %@" , year, region)
            }
        }
        
        if let summaries = (try? context.fetch(request)) as? [Summary] {
            return summaries
        }  else {
            return []
        }

    }

    
    // Return all records for an election year - selected fields
    class func getBasicSummariesForElectionRegion(year:String, region:String, sortColumns:[String],searchText:String, inManagedObjectContext context: NSManagedObjectContext) ->  [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.propertiesToFetch = ["year","onsid","constituency.constituencyName","constituency.regionName","party.name","party.colour","fullName","majorityPercent","runnerupparty.colour","prevParty.colour"]
        request.resultType = .dictionaryResultType
        
        // Set sort order
        var sortDescriptors:[NSSortDescriptor] = []
        for sortColumn in sortColumns {
            switch sortColumn {
            case "Region":
                sortDescriptors.append(NSSortDescriptor(key: "constituency.regionName", ascending: true))
            case "Constituency":
                sortDescriptors.append(NSSortDescriptor(key: "constituency.constituencyName", ascending: true))
            case "Winning Party":
                sortDescriptors.append(NSSortDescriptor(key: "party.name", ascending: true))
            case "Elected MP":
                sortDescriptors.append(NSSortDescriptor(key: "surname", ascending: true))
                sortDescriptors.append(NSSortDescriptor(key: "firstName", ascending: true))
            case "Majority %":
                sortDescriptors.append(NSSortDescriptor(key: "majorityPercent", ascending: true))
            case "Previous Party":
                sortDescriptors.append(NSSortDescriptor(key: "prevParty.name", ascending: true))
            case "Runner-up Party":
                sortDescriptors.append(NSSortDescriptor(key: "runnerupparty.name", ascending: true))
            case "Party Changed":
                sortDescriptors.append(NSSortDescriptor(key: "partyChanged", ascending: false))
            default:
                break
            }
        }        
        request.sortDescriptors = sortDescriptors
        
        // Filter results by search and region
        if searchText != "" {
            if region == "UK Wide" {
                request.predicate = NSPredicate(format: "year = %@ and (constituency.constituencyName contains[c] %@ or fullName contains[c] %@ or party.name contains[c] %@ or constituency.regionName contains[c] %@ or (ANY detailResults.fullName =[c] %@)) " , year, searchText, searchText, searchText, searchText, searchText, searchText)
            } else {
                request.predicate = NSPredicate(format: "year = %@ and constituency.regionName = %@ and (constituency.constituencyName contains[c] %@ or fullName contains[c] %@ or party.name contains[c] %@ or constituency.regionName contains[c] %@ or (ANY detailResults.fullName =[c] %@)) " , year, region, searchText, searchText, searchText, searchText, searchText, searchText)
            }
        } else {
            if region == "UK Wide" {
                request.predicate = NSPredicate(format: "year = %@" , year)
            } else {
                request.predicate = NSPredicate(format: "year = %@ and constituency.regionName = %@" , year, region)
            }
        }
        
        if let summaries = (try? context.fetch(request)) as?  [[String:AnyObject]] {
            return summaries
        }  else {
            return [[:]]
        }
        
    }

    // Get valid votes for region
    class func getRegionVotes(year:String, region:String, inManagedObjectContext context: NSManagedObjectContext) -> Int32 {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.propertiesToFetch = ["validVotes"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and constituency.regionName = %@", year, region)

        if var summariesDict = (try? context.fetch(request)) as? [[String:AnyObject]] {
            var validVotes:Int32 = 0
            for summary in summariesDict {
                validVotes += (summary["validVotes"] as! Int32)
            }
            summariesDict = [[:]]
            return validVotes
        } else {
            return 0
        }
    }
    
    // Get valid votes for each constituency
    class func getConstituencyVotes(year:String, inManagedObjectContext context: NSManagedObjectContext) -> (constituencies:[String],validVotes:[Int32]) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.propertiesToFetch = ["onsid","validVotes"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@", year)
        request.sortDescriptors = [NSSortDescriptor(key:"onsid", ascending: true)]
        
        if var summariesDict = (try? context.fetch(request)) as? [[String:AnyObject]] {
            var constituencies:[String] = []
            var validVotes:[Int32] = []
            for summary in summariesDict {
                constituencies.append(summary["onsid"] as! String)
                validVotes.append(summary["validVotes"] as! Int32)
            }
            summariesDict = [[:]]
            return (constituencies, validVotes)
        } else {
            return ([],[])
        }
    }
    
    // Insert one record
    class func loadSummary(item: (year:String, onsid:String, partyCode:String, firstName:String, surname:String, electorate: Int32?, validVotes: Int32?, invalidVotes: Int32?, majority: Int32?, majorityPercent: Double?, runnerUp: String, narrative: String, previousParty: String), inManagedObjectContext context: NSManagedObjectContext) -> Summary?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.predicate = NSPredicate(format: "onsid = %@ AND year = %@", item.onsid, item.year)
        
        if let summary = (try? context.fetch(request))?.first as? Summary {
            return summary
        } else if let summary = NSEntityDescription.insertNewObject(forEntityName: "Summary", into: context) as? Summary {
            summary.year = item.year
            summary.onsid = item.onsid
            summary.partyCode = item.partyCode
            summary.firstName = item.firstName
            summary.surname = item.surname
            summary.fullName = item.firstName + " " + item.surname
            summary.electorate = item.electorate!
            summary.validVotes = item.validVotes!
            summary.invalidVotes = item.invalidVotes!
            summary.majority = item.majority!
            summary.majorityPercent = Double(item.majorityPercent!)
            summary.runnerUp = item.runnerUp
            summary.narrative = item.narrative
            summary.previousParty = item.previousParty
            if item.partyCode != item.previousParty {
                summary.partyChanged = "Y"
            } else {
                summary.partyChanged = "N"
            }
            
            summary.party = Party.loadParty(item: (item.partyCode, item.partyCode, "#DDDDDDFF"), inManagedObjectContext: context)
            summary.runnerupparty = Party.loadParty(item: (item.runnerUp, item.runnerUp, "#DDDDDDFF"), inManagedObjectContext: context)
            summary.constituency = Constituency.loadConstituency(item: (item.onsid, constituencyName: "", country:"", regionName: "", countyName: ""), inManagedObjectContext: context)
            summary.prevParty = Party.loadParty(item: (item.previousParty, item.previousParty, "#DDDDDDFF"), inManagedObjectContext: context)

            return summary
        }
        return nil
    }
    
    // Delete all records
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.includesPropertyValues = false
        
        if var summaries = (try? context.fetch(request)) as? [Summary] {
            for summary in summaries {
                context.delete(summary)
            }
            summaries = []
        }
    }

    // Delete all records for an election from table
    class func removeElectionData (election: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.predicate = NSPredicate(format: "year = %@", election)
        request.includesPropertyValues = false
        
        if let summaries = (try? context.fetch(request)) as? [Summary] {
            for summary in summaries {
                context.delete(summary)
            }
        }
    }
    
    // Set up records for a simulation from the based on election data
    class func setupSimulationData (election: String, basedOnYear: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.predicate = NSPredicate(format: "year = %@", basedOnYear)
        
        if var summaries = (try? context.fetch(request)) as? [Summary] {
            for summary in summaries {
                
                if let addSummary = NSEntityDescription.insertNewObject(forEntityName: "Summary", into: context) as? Summary {
                    addSummary.year = election
                    addSummary.onsid = summary.onsid
                    addSummary.partyCode = ""
                    addSummary.firstName = ""
                    addSummary.surname = ""
                    addSummary.fullName = ""
                    addSummary.electorate = summary.electorate
                    addSummary.validVotes = summary.validVotes
                    addSummary.invalidVotes = summary.invalidVotes
                    addSummary.majority = 0
                    addSummary.majorityPercent = 0
                    addSummary.runnerUp = ""
                    addSummary.narrative = ""
                    addSummary.previousParty = summary.partyCode
                    addSummary.partyChanged = "N"

                    addSummary.party = nil
                    addSummary.runnerupparty = nil
                    addSummary.constituency = summary.constituency
                    addSummary.prevParty = summary.party
                }
            }
            summaries = []
        }
    }

    // Update constituency results
    class func updateResults(year: String, onsid: String, partyCode: String, firstName: String, surname: String, majority: Int32, runnerUp: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Summary")
        request.predicate = NSPredicate(format: "year = %@ and onsid = %@", year, onsid)
        
        if let summary = (try? context.fetch(request))?.first as? Summary {
            summary.partyCode = partyCode
            summary.firstName = firstName
            summary.fullName = firstName + " " + surname
            summary.majority = majority
            summary.runnerUp = runnerUp
            summary.majorityPercent = Double(majority) / Double(summary.validVotes) * 100.0
            if summary.partyCode != summary.previousParty {
                summary.partyChanged = "Y"
                summary.narrative = summary.partyCode! + " gain from " + summary.previousParty!
            } else {
                summary.partyChanged = "N"
                summary.narrative = summary.partyCode! + " hold"
            }
            summary.party = Party.loadParty(item: (summary.partyCode!, summary.partyCode!, "#DDDDDDFF"), inManagedObjectContext: context)
            summary.runnerupparty = Party.loadParty(item: (summary.runnerUp!, summary.runnerUp!, "#DDDDDDFF"), inManagedObjectContext: context)
        }
    }


}
