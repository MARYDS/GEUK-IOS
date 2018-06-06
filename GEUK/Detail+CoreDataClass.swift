//
//  Detail+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 24/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(Detail)
public class Detail: NSManagedObject {

    // Get detail results for an election / simulation
    class func getDetailsForElection(year:String, sortOrder:[String], sortAsc:[Bool], inManagedObjectContext context: NSManagedObjectContext) -> [Detail] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.predicate = NSPredicate(format: "year = %@", year)

        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let details = (try? context.fetch(request)) as? [Detail] {
            return details
        }  else {
            return []
        }
    }
    
    // Get basic detail results for an election / simulation
    class func getBasicDetailsForElection(year:String, sortOrder:[String], sortAsc:[Bool], inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.propertiesToFetch = ["onsid","constituency.constituencyName","constituency.regionName","partyCode","share"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@", year)
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let details = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return details
        }  else {
            return [[:]]
        }
    }
    
    // Get detail results for an election / simulation for a constituency - selected fields
    class func getDetailsForConstituency(year:String, constituency:String, sortOrder:[String], sortAsc:[Bool], inManagedObjectContext context: NSManagedObjectContext) -> [Detail] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.predicate = NSPredicate(format: "year = %@ and onsid = %@", year, constituency)
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let details = (try? context.fetch(request)) as? [Detail] {
            return details
        }  else {
            return []
        }
    }
    
    
    // Get detail results for an election / simulation for a constituency - selected fields
    class func getBasicDetailsForConstituency(year:String, constituency:String, sortOrder:[String], sortAsc:[Bool], inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.propertiesToFetch = ["party.colour","party.name","fullName","votes","share","change"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and onsid = %@", year, constituency)
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let details = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return details
        }  else {
            return [[:]]
        }
    }
    
    // Insert one detail record
    class func loadDetail(item: (year:String, onsid:String, partyCode:String, firstName:String, surname:String, gender: String, votes: Int32?, share: Double?, change: Double?), inManagedObjectContext context: NSManagedObjectContext) -> Detail?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.predicate = NSPredicate(format: "onsid = %@ AND year = %@ AND partyCode = %@ AND surname = %@", item.onsid, item.year, item.partyCode, item.surname)
        
        if let detail = (try? context.fetch(request))?.first as? Detail {
            return detail
        } else if let detail = NSEntityDescription.insertNewObject(forEntityName: "Detail", into: context) as? Detail {
            detail.year = item.year
            detail.onsid = item.onsid
            detail.partyCode = item.partyCode
            detail.firstName = item.firstName
            detail.surname = item.surname
            detail.fullName = item.firstName + " " + item.surname
            detail.gender = item.gender
            detail.votes = item.votes!
            detail.share = Double(item.share!)
            detail.change = Double(item.change!)
            detail.party = Party.loadParty(item: (item.partyCode, item.partyCode, "#DDDDDDFF"), inManagedObjectContext: context)
            detail.constituency = Constituency.loadConstituency(item: (item.onsid, constituencyName: "", country:"", regionName: "", countyName: ""), inManagedObjectContext: context)
            detail.summaryResults = Summary.loadSummary(item: (year: item.year, onsid: item.onsid, partyCode: "", firstName: "", surname: "", electorate: 0, validVotes: 0, invalidVotes: 0, majority: 0, majorityPercent: 0.0, runnerUp: "", narrative: "", previousParty: ""), inManagedObjectContext: context)
            return detail
        }
        return nil
    }
    
    // Delete all records from table
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.includesPropertyValues = false
        
        if let details = (try? context.fetch(request)) as? [Detail] {
            for detail in details {
                context.delete(detail)
            }
        }
    }
    
    // Delete all records for an election from table
    class func removeElectionData (election: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.includesPropertyValues = false
        request.predicate = NSPredicate(format: "year = %@", election)
     
        if var details = (try? context.fetch(request)) as? [Detail] {
            for detail in details {
                context.delete(detail)
            }
            details = []
        }
    }
    
    // Set up records for a simulation from the based on election data
    class func setupSimulationData (election: String, basedOnYear: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.predicate = NSPredicate(format: "year = %@", basedOnYear)
        
        if var details = (try? context.fetch(request)) as? [Detail] {
            for detail in details {
                
                if let addDetail = NSEntityDescription.insertNewObject(forEntityName: "Detail", into: context) as? Detail {
                    addDetail.year = election
                    addDetail.onsid = detail.onsid
                    addDetail.partyCode = detail.partyCode
                    addDetail.firstName = detail.firstName
                    addDetail.surname = detail.surname
                    addDetail.fullName = detail.fullName
                    addDetail.gender = detail.gender
                    addDetail.votes = detail.votes
                    addDetail.share = detail.share
                    addDetail.change = 0

                    addDetail.party = detail.party
                    addDetail.constituency = detail.constituency
                    addDetail.summaryResults = Summary.loadSummary(item: (year: election, onsid: detail.onsid!, partyCode: "", firstName: "", surname: "", electorate: 0, validVotes: 0, invalidVotes: 0, majority: 0, majorityPercent: 0, runnerUp: "", narrative: "", previousParty: ""), inManagedObjectContext: context)
                }
            }
            details = []
        }
    }
    
    // Transfer votes from/to a candidate
    class func transferVotes(year: String, onsid: String, partyCode: String, transferVotes: Int32, change: Double, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        request.predicate = NSPredicate(format: "year = %@ and onsid = %@ and partyCode = %@", year, onsid, partyCode)
        
        if let detail = (try? context.fetch(request))?.first as? Detail {
            detail.share = change + detail.share
            detail.votes = detail.votes + transferVotes
            detail.change = change
        }
    }


}
