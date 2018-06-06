//
//  SimPartyConstituencies+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 16/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(SimPartyConstituencies)
public class SimPartyConstituencies: NSManagedObject {
    
    // Return all records for an election year, region
    class func getSimPartyConsRegion(year:String, region:String, inManagedObjectContext context: NSManagedObjectContext) -> [SimPartyConstituencies] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SimPartyConstituencies")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@", year, region)
        if let simPartyCons = (try? context.fetch(request)) as? [SimPartyConstituencies] {
            return simPartyCons
        }  else {
            return []
        }
    }
    
    // Return all records for an election year, region - selected fields
    class func getBasicSimPartyConsRegion(year:String, region:String, inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SimPartyConstituencies")
        request.propertiesToFetch = ["partyFrom","partyTo","constituencyCount"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@", year, region)
        if let simPartyCons = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return simPartyCons
        }  else {
            return [[:]]
        }
    }
   
    class func loadSimPartyConstituency(item: (year:String, regionName:String, partyFrom:String, partyTo:String, constituencyCount: Int32, electorate:Int32, partyFromVotes: Int32, partyToVotes: Int32), inManagedObjectContext context: NSManagedObjectContext) -> SimPartyConstituencies?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SimPartyConstituencies")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@ and partyFrom = %@ and partyTo = %@", item.year, item.regionName, item.partyFrom, item.partyTo)
        
        if let simPartyConstituency = (try? context.fetch(request))?.first as? SimPartyConstituencies {
            return simPartyConstituency
        } else if let simPartyConstituency = NSEntityDescription.insertNewObject(forEntityName: "SimPartyConstituencies", into: context) as? SimPartyConstituencies {
            simPartyConstituency.year = item.year
            simPartyConstituency.regionName = item.regionName
            simPartyConstituency.partyFrom = item.partyFrom
            simPartyConstituency.partyTo = item.partyTo
            simPartyConstituency.constituencyCount = item.constituencyCount
            simPartyConstituency.electorate = item.electorate
            simPartyConstituency.partyFromVotes = item.partyFromVotes
            simPartyConstituency.partyToVotes = item.partyToVotes
            simPartyConstituency.from = Party.loadParty(item: (item.partyFrom, item.partyFrom, "#DDDDDDFF"), inManagedObjectContext: context)
            simPartyConstituency.to = Party.loadParty(item: (item.partyTo, item.partyTo, "#DDDDDDFF"), inManagedObjectContext: context)
            return simPartyConstituency
        }
        return nil
    }
    
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SimPartyConstituencies")
        request.includesPropertyValues = false
        
        if let simPartyConstituencies = (try? context.fetch(request)) as? [SimPartyConstituencies] {
            for simPartyConstituency in simPartyConstituencies {
                context.delete(simPartyConstituency)
            }
        }
    }

}
