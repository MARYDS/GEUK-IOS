//
//  ConstituencyLocAuth+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 29/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(ConstituencyLocAuth)
public class ConstituencyLocAuth: NSManagedObject {
    
    // Get EU referendum results for a constituency
    class func getReferendumResults(onsid:String, sortOrder:[String], sortAsc:[Bool], inManagedObjectContext context: NSManagedObjectContext) -> [ConstituencyLocAuth] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ConstituencyLocAuth")
        request.predicate = NSPredicate(format: "onsid = %@", onsid)
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let refResults = (try? context.fetch(request)) as? [ConstituencyLocAuth] {
            return refResults
        }  else {
            return []
        }
    }
    
    // Get EU referendum results for a constituency
    class func getBasicReferendumResults(onsid:String, sortOrder:[String], sortAsc:[Bool], inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ConstituencyLocAuth")
        request.propertiesToFetch = ["referendum.areaName","wardsCon", "wardsLA", "referendum.electorate","referendum.turnoutPercent","referendum.remainVotes","referendum.remainPercent","referendum.leaveVotes","referendum.leavePercent"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "onsid = %@", onsid)
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let refResults = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return refResults
        }  else {
            return [[:]]
        }
    }
    
    // Get Constituencies for a region
    class func getConstituenciesForRegion(areaName:String, inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ConstituencyLocAuth")
        request.propertiesToFetch = ["constituency.onsid","constituency.constituencyName","wardsCon", "wardsLA"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "referendum.areaName = %@", areaName)
        
        var sortOrder = ["wardsCon", "constituency.constituencyName"]
        var sortAsc = [false, true]
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let regConResults = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return regConResults
        }  else {
            return [[:]]
        }
    }

    // Insert one row
    class func loadLink(item: (onsid: String, areaCode: String, wardsCon: Int32?, wardsLA: Int32?), inManagedObjectContext context: NSManagedObjectContext) -> ConstituencyLocAuth?
    {
        if let conLocAuth = NSEntityDescription.insertNewObject(forEntityName: "ConstituencyLocAuth", into: context) as? ConstituencyLocAuth {
            conLocAuth.onsid = item.onsid
            conLocAuth.areaCode = item.areaCode
            conLocAuth.wardsCon = item.wardsCon!
            conLocAuth.wardsLA = item.wardsLA!
            conLocAuth.constituency = Constituency.loadConstituency(item: (item.onsid, constituencyName: "", country:"", regionName: "", countyName: ""), inManagedObjectContext: context)
            conLocAuth.referendum = EUReferendum.loadReferendum(item: (region: "", areaCode: item.areaCode, areaName:"", electorate: 0, turnoutPercent: 0.0, remainVotes: 0, leaveVotes: 0, remainPercent: 0.0, leavePercent: 0.0), inManagedObjectContext: context)

            return conLocAuth
        }
        return nil
    }
    
    // Remove all Constituency Local Authority link records
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ConstituencyLocAuth")
        request.includesPropertyValues = false
        
        if let conLAs = (try? context.fetch(request)) as? [ConstituencyLocAuth] {
            for conLA in conLAs {
                context.delete(conLA)
            }
        }
    }
    
    
    
}
