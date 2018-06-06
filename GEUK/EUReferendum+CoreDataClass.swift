//
//  EUReferendum+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 29/12/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(EUReferendum)
public class EUReferendum: NSManagedObject {
    
    // Get all EU referendum results
    class func getAllReferendumResults(region:String, sortOrder:[String], sortAsc:[Bool],inManagedObjectContext context: NSManagedObjectContext) -> [EUReferendum] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EUReferendum")
        if region != "UK Wide" {
            request.predicate = NSPredicate(format: "region = %@", region)
        }

        var sortDescriptors:[NSSortDescriptor] = []

        if sortOrder.count > 0 {
            var cnt = 0
            for sortColumn in sortOrder {
                switch sortColumn {
                case "Region":
                    sortDescriptors.append(NSSortDescriptor(key: "region", ascending: sortAsc[cnt]))
                case "Local Authority":
                    sortDescriptors.append(NSSortDescriptor(key: "areaName", ascending: sortAsc[cnt]))
                case "Electorate":
                    sortDescriptors.append(NSSortDescriptor(key: "electorate", ascending: sortAsc[cnt]))
                case "Turnout%":
                    sortDescriptors.append(NSSortDescriptor(key: "turnoutPercent", ascending: sortAsc[cnt]))
                case "Remain":
                    sortDescriptors.append(NSSortDescriptor(key: "remainVotes", ascending: sortAsc[cnt]))
                case "Remain%":
                    sortDescriptors.append(NSSortDescriptor(key: "remainPercent", ascending: sortAsc[cnt]))
                case "Leave":
                    sortDescriptors.append(NSSortDescriptor(key: "leaveVotes", ascending: sortAsc[cnt]))
                case "Leave%":
                    sortDescriptors.append(NSSortDescriptor(key: "leavePercent", ascending: sortAsc[cnt]))
                default:
                    break
                }
                cnt += 1
            }
            
            request.sortDescriptors = sortDescriptors
        }
        
        if let euResults = (try? context.fetch(request)) as? [EUReferendum] {
            return euResults
        }  else {
            return []
        }
    }
    
    
    // Get all EU referendum results - selected fields
    class func getBasicAllReferendumResults(region:String, sortOrder:[String], sortAsc:[Bool],inManagedObjectContext context: NSManagedObjectContext) -> [[String:AnyObject]] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EUReferendum")
        request.propertiesToFetch = ["region","areaName","electorate","turnoutPercent","remainVotes","remainPercent","leaveVotes","leavePercent"]
        request.resultType = .dictionaryResultType
        if region != "UK Wide" {
            request.predicate = NSPredicate(format: "region = %@", region)
        }
        
        var sortDescriptors:[NSSortDescriptor] = []
        
        if sortOrder.count > 0 {
            var cnt = 0
            for sortColumn in sortOrder {
                switch sortColumn {
                case "Region":
                    sortDescriptors.append(NSSortDescriptor(key: "region", ascending: sortAsc[cnt]))
                case "Local Authority":
                    sortDescriptors.append(NSSortDescriptor(key: "areaName", ascending: sortAsc[cnt]))
                case "Electorate":
                    sortDescriptors.append(NSSortDescriptor(key: "electorate", ascending: sortAsc[cnt]))
                case "Turnout%":
                    sortDescriptors.append(NSSortDescriptor(key: "turnoutPercent", ascending: sortAsc[cnt]))
                case "Remain":
                    sortDescriptors.append(NSSortDescriptor(key: "remainVotes", ascending: sortAsc[cnt]))
                case "Remain%":
                    sortDescriptors.append(NSSortDescriptor(key: "remainPercent", ascending: sortAsc[cnt]))
                case "Leave":
                    sortDescriptors.append(NSSortDescriptor(key: "leaveVotes", ascending: sortAsc[cnt]))
                case "Leave%":
                    sortDescriptors.append(NSSortDescriptor(key: "leavePercent", ascending: sortAsc[cnt]))
                default:
                    break
                }
                cnt += 1
            }
            
            request.sortDescriptors = sortDescriptors
        }
        
        if let euResults = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return euResults
        }  else {
            return [[:]]
        }
    }
    
    // Insert one row
    class func loadReferendum(item: (region: String, areaCode: String, areaName:String, electorate: Int32?, turnoutPercent: Double?, remainVotes: Int32?, leaveVotes: Int32?, remainPercent: Double?, leavePercent: Double?), inManagedObjectContext context: NSManagedObjectContext) -> EUReferendum?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EUReferendum")
        request.predicate = NSPredicate(format: "areaCode = %@", item.areaCode)
        
        if let referendum = (try? context.fetch(request))?.first as? EUReferendum {
            return referendum
        } else if let referendum = NSEntityDescription.insertNewObject(forEntityName: "EUReferendum", into: context) as? EUReferendum {
            referendum.region = item.region
            referendum.areaCode = item.areaCode
            referendum.areaName = item.areaName
            referendum.electorate = item.electorate!
            referendum.turnoutPercent = item.turnoutPercent!
            referendum.remainVotes = item.remainVotes!
            referendum.leaveVotes = item.leaveVotes!
            referendum.remainPercent = item.remainPercent!
            referendum.leavePercent = item.leavePercent!
            return referendum
        }
        return nil
    }
    
    // Remove all election record
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EUReferendum")
        request.includesPropertyValues = false
        
        if let refResults = (try? context.fetch(request)) as? [EUReferendum] {
            for refResult in refResults {
                context.delete(refResult)
            }
        }
    }

}
