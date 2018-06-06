//
//  PartySummary+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 02/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(PartySummary)
public class PartySummary: NSManagedObject {

    // Get one result for Year, Region and Party Code
    class func getPartyResult(year:String, region:String, party:String, inManagedObjectContext context: NSManagedObjectContext) -> [PartySummary] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@ and partyCode = %@", year, region, party)
        if let partySummaries = (try? context.fetch(request)) as? [PartySummary] {
            return partySummaries
        }  else {
            return []
        }
    }
 
    
    // Get one result for Year, Region and Party Code - selected fields
    class func getBasicPartyResult(year:String, region:String, party:String, inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.propertiesToFetch = ["party.colour","votesPercent"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@ and partyCode = %@", year, region, party)
        if let partySummaries = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return partySummaries
        }  else {
            return [[:]]
        }
    }
    
    // Get multiple results for Year, Region and other parties
    class func getOtherPartyResult(year:String, region:String, parties:[String], inManagedObjectContext context: NSManagedObjectContext) -> [PartySummary] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@ and NOT(partyCode IN %@)", year, region, parties)
        if let partySummaries = (try? context.fetch(request)) as? [PartySummary] {
            return partySummaries
        }  else {
            return []
        }
    }
    
    // Get multiple results for Year, Region and other parties - selected fields
    class func getBasicOtherPartyResult(year:String, region:String, parties:[String], inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.propertiesToFetch = ["candidates","votesPercent"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@ and NOT(partyCode IN %@)", year, region, parties)
        if let partySummaries = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return partySummaries
        }  else {
            return [[:]]
        }
    }
    
    // Get all party results for Year, Region and Party Code
    class func getAllPartyResults(year:String, region:String, sortOrder:[String], sortAsc:[Bool],inManagedObjectContext context: NSManagedObjectContext) -> [PartySummary] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@", year, region)
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let partySummaries = (try? context.fetch(request)) as? [PartySummary] {
            return partySummaries
        }  else {
            return []
        }
    }
    
    // Get all party results for Year, Region and Party Code - selected fields
    class func getBasicAllPartyResults(year:String, region:String, sortOrder:[String], sortAsc:[Bool],inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.propertiesToFetch = ["party.colour","party.name","seats","candidates","votes","votesPercent","changePercent"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@", year, region)
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let partySummaries = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return partySummaries
        }  else {
            return [[:]]
        }
    }
    
    // Insert one record
    class func loadPartySummary(item: (year: String, regionName: String, partyCode: String, seats: Int32?, candidates: Int32?, votes: Int32?, votesPercent: Double?, changePercent: Double?), inManagedObjectContext context: NSManagedObjectContext) -> PartySummary?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@ and partyCode = %@", item.year, item.regionName, item.partyCode)
        
        if let partySummary = (try? context.fetch(request))?.first as? PartySummary {
            return partySummary
        } else if let partySummary = NSEntityDescription.insertNewObject(forEntityName: "PartySummary", into: context) as? PartySummary {
            partySummary.year = item.year
            partySummary.regionName = item.regionName
            partySummary.partyCode = item.partyCode
            partySummary.seats = item.seats!
            partySummary.candidates = item.candidates!
            partySummary.votes = item.votes!
            partySummary.votesPercent = Double(item.votesPercent!)
            partySummary.changePercent = Double(item.changePercent!)
            partySummary.party = Party.loadParty(item: (item.partyCode, item.partyCode, "#DDDDDDFF"), inManagedObjectContext: context)

            return partySummary
        }
        return nil
    }
    
    // Delete all records
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.includesPropertyValues = false
        
        if let partySummaries = (try? context.fetch(request)) as? [PartySummary] {
            for partySummary in partySummaries {
                context.delete(partySummary)
            }
        }
    }
    
    // Delete all records for an election from table
    class func removeElectionData (election: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.predicate = NSPredicate(format: "year = %@", election)
        request.includesPropertyValues = false
        
        if var partySummaries = (try? context.fetch(request)) as? [PartySummary] {
            for partySummary in partySummaries {
                context.delete(partySummary)
            }
            partySummaries = []
        }
    }
    
    // Set up records for a simulation from the based on election data
    class func setupSimulationData (election: String, basedOnYear: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.predicate = NSPredicate(format: "year = %@", basedOnYear)
        
        if var partySummaries = (try? context.fetch(request)) as? [PartySummary] {
            for partySummary in partySummaries {
                
                if let addPartySummary = NSEntityDescription.insertNewObject(forEntityName: "PartySummary", into: context) as? PartySummary {
                    addPartySummary.year = election
                    addPartySummary.regionName = partySummary.regionName
                    addPartySummary.partyCode = partySummary.partyCode
                    addPartySummary.seats = 0
                    addPartySummary.candidates = partySummary.candidates
                    addPartySummary.votes = 0
                    addPartySummary.votesPercent = partySummary.votesPercent
                    addPartySummary.changePercent = 0.0
                    addPartySummary.party = partySummary.party
                }
            }
            partySummaries = []
        }
    }
    
    
    // Update party results
    class func updateResults(year: String, regionName: String, partyCode: String, seats: Int32, votes: Int32, votesPercent: Double, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PartySummary")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@ and partyCode = %@", year, regionName, partyCode)
        
        if let partySummary = (try? context.fetch(request))?.first as? PartySummary {
            partySummary.changePercent = votesPercent - partySummary.votesPercent
            partySummary.seats = seats
            partySummary.votes = votes
            partySummary.votesPercent = votesPercent
        }
    }

    
}
