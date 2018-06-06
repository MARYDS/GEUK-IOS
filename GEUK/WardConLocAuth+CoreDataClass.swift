//
//  WardConLocAuth+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 12/01/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(WardConLocAuth)
public class WardConLocAuth: NSManagedObject {
    
    // Get ward list for a constituency
    class func getWardList(onsid:String, sortOrder:[String], sortAsc:[Bool], inManagedObjectContext context: NSManagedObjectContext) -> [WardConLocAuth] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WardConLocAuth")
        request.predicate = NSPredicate(format: "onsid = %@", onsid)
        
        if sortOrder.count > 0 {
            var sortDescriptors:[NSSortDescriptor] = []
            for i in 0...sortOrder.count - 1 {
                sortDescriptors.append(NSSortDescriptor(key: sortOrder[i], ascending: sortAsc[i]))
            }
            request.sortDescriptors = sortDescriptors
        }
        
        if let refResults = (try? context.fetch(request)) as? [WardConLocAuth] {
            return refResults
        }  else {
            return []
        }
    }
    
    // Insert one row
    class func loadLink(item: (wardId:String, wardName:String, onsid: String, areaId: String, areaName: String), inManagedObjectContext context: NSManagedObjectContext) -> WardConLocAuth?
    {
        if let wardConLocAuth = NSEntityDescription.insertNewObject(forEntityName: "WardConLocAuth", into: context) as? WardConLocAuth {
            
            wardConLocAuth.wardId = item.wardId
            wardConLocAuth.wardName = item.wardName
            wardConLocAuth.onsid = item.onsid
            wardConLocAuth.areaId = item.areaId
            wardConLocAuth.areaName = item.areaName
            
            return wardConLocAuth
        }
        return nil
    }
    
    // Remove all Ward, Constituency Local Authority link records
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WardConLocAuth")
        request.includesPropertyValues = false
        
        if let wardConLAs = (try? context.fetch(request)) as? [WardConLocAuth] {
            for wardConLA in wardConLAs {
                context.delete(wardConLA)
            }
        }
    }
    

}
