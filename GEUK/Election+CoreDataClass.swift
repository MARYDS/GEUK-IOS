//
//  Election+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 30/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(Election)
public class Election: NSManagedObject {

    // Return details for an election year
    class func getElection(year:String, inManagedObjectContext context: NSManagedObjectContext) -> [Election] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Election")
        request.predicate = NSPredicate(format: "year = %@", year)
        if let election = (try? context.fetch(request)) as? [Election] {
            return election
        }  else {
            return []
        }
    }
    
    // Return details for previous election year
    class func getPreviousElection(year:String, sortOrder: [String], sortAsc: [Bool], inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Election")
        request.propertiesToFetch = ["year"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year < %@ and NOT(year CONTAINS %@)", year, "Sim")
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }

        if let election = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return election
        }  else {
            return [[:]]
        }
    }
    
    // Return details for next election year
    class func getNextElection(year:String, sortOrder: [String], sortAsc: [Bool], inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Election")
        request.propertiesToFetch = ["year"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year > %@ and NOT(year CONTAINS %@)", year, "Sim")

        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let election = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return election
        }  else {
            return [[:]]
        }
    }
    
    // Return details of all elections in descending order
    class func getElections(inManagedObjectContext context: NSManagedObjectContext) -> [Election] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Election")
        request.sortDescriptors = [NSSortDescriptor(key:"year", ascending: false)]

        if let elections = (try? context.fetch(request)) as? [Election] {
            return elections
        }  else {
            return []
        }
    }

    // Insert one row
    class func loadElection(item: (year: String, electorate: Int32?, validVotes: Int32?, invalidVotes: Int32?, turnoutPercent: Double?), inManagedObjectContext context: NSManagedObjectContext) -> Election?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Election")
        request.predicate = NSPredicate(format: "year = %@", item.year)
        
        if let election = (try? context.fetch(request))?.first as? Election {
            return election
        } else if let election = NSEntityDescription.insertNewObject(forEntityName: "Election", into: context) as? Election {
            election.year = item.year
            election.electorate = item.electorate!
            election.validVotes = item.validVotes!
            election.invalidVotes = item.invalidVotes!
            election.turnoutPercent = item.turnoutPercent!
            return election
        }
        return nil
    }
    
    // Remove all records
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Election")
        request.includesPropertyValues = false
        
        if var elections = (try? context.fetch(request)) as? [Election] {
            for election in elections {
                context.delete(election)
            }
            elections = []
        }
    }
    
    // Remove one election record
    class func removeElectionData (election: String, inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Election")
        request.predicate = NSPredicate(format: "year = %@", election)
        request.includesPropertyValues = false
        
        if let elections = (try? context.fetch(request)) as? [Election] {
            for election in elections {
                context.delete(election)
            }
        }
    }

    // Set up records for a simulation from the based on election data
    class func setupSimulationData (election: String, basedOnYear: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Election")
        request.predicate = NSPredicate(format: "year = %@", basedOnYear)
        
        if var elections = (try? context.fetch(request)) as? [Election] {
            for theElection in elections {
                
                if let addElection = NSEntityDescription.insertNewObject(forEntityName: "Election", into: context) as? Election {
                    addElection.year = election
                    addElection.electorate = theElection.electorate
                    addElection.validVotes = theElection.validVotes
                    addElection.invalidVotes = theElection.invalidVotes
                    addElection.turnoutPercent = theElection.turnoutPercent
                }
            }
            elections = []
        }
    }

}
