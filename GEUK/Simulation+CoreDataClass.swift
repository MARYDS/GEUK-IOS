//
//  Simulation+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 12/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(Simulation)
public class Simulation: NSManagedObject {

    // Return a set of simulation rules for simulation and region
    class func getRulesForSimulation(simulation:String, region:String, inManagedObjectContext context: NSManagedObjectContext) -> [Simulation] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Simulation")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@", simulation, region)
        if let simRules = (try? context.fetch(request)) as? [Simulation] {
            return simRules
        }  else {
            return []
        }
    }
    
    // Return a set of simulation rules for simulation and region - selected fields
    class func getBasicRulesForSimulation(simulation:String, region:String, inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Simulation")
        request.propertiesToFetch = ["fromPartyCode","toPartyCode","changePercent"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@", simulation, region)
        if let simRules = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return simRules
        }  else {
            return [[:]]
        }
    }

    // eturn a set of simulation rules for simulation and region as from/to and change percent
    class func getRulesBasic(year:String, region:String, inManagedObjectContext context: NSManagedObjectContext) -> (fromTo:[String],changePercent:[Double]) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Simulation")
        request.propertiesToFetch = ["fromPartyCode","toPartyCode","changePercent"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@", year, region)
        
        if var rulesDict = (try? context.fetch(request)) as? [[String:AnyObject]] {
            var fromTo:[String] = []
            var changePercent:[Double] = []
            for rule in rulesDict {
                fromTo.append((rule["fromPartyCode"] as! String) + (rule["toPartyCode"] as! String))
                changePercent.append(rule["changePercent"] as! Double)
            }
            rulesDict = [[:]]
            return (fromTo, changePercent)
        } else {
            return ([],[])
        }
    }

    class func loadSimulation(item: (year:String, regionName:String, fromPartyCode:String, toPartyCode:String, changePercent:Double), inManagedObjectContext context: NSManagedObjectContext) -> Simulation?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Simulation")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@ and fromPartyCode = %@ and toPartyCode = %@", item.year, item.regionName, item.fromPartyCode, item.toPartyCode)
        
        if let simulation = (try? context.fetch(request))?.first as? Simulation {
            return simulation
        } else if let simulation = NSEntityDescription.insertNewObject(forEntityName: "Simulation", into: context) as? Simulation {
            simulation.year = item.year
            simulation.regionName = item.regionName
            simulation.fromPartyCode = item.fromPartyCode
            simulation.toPartyCode = item.toPartyCode
            simulation.changePercent = item.changePercent
            simulation.fromParty = Party.loadParty(item: (item.fromPartyCode, item.fromPartyCode, "#DDDDDDFF"), inManagedObjectContext: context)
            simulation.toParty = Party.loadParty(item: (item.toPartyCode, item.toPartyCode, "#DDDDDDFF"), inManagedObjectContext: context)            
            return simulation
        }
        return nil
    }
    
    class func removeData (year:String, regionName:String, inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Simulation")
        request.predicate = NSPredicate(format: "year = %@ and regionName = %@", year, regionName)
        request.includesPropertyValues = false

        if let simulationItems = (try? context.fetch(request)) as? [Simulation] {
            for simulationItem in simulationItems {
                context.delete(simulationItem)
            }
        }
    }

}
