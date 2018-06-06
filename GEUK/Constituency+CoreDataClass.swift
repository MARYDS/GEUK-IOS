//
//  Constituency+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 24/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(Constituency)
public class Constituency: NSManagedObject {

    
    // Return details of all regions
    class func getRegions(inManagedObjectContext context: NSManagedObjectContext) -> [String] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Constituency")
        request.propertiesToFetch = ["regionName"]
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.sortDescriptors = [NSSortDescriptor(key:"regionName", ascending: true)]
        
        if var regionsDict = (try? context.fetch(request)) as? [[String:AnyObject]] {
            regionsDict.append(["regionName":("UK Wide") as AnyObject])
            var regions:[String] = []
            for region in regionsDict {
                regions.append(region["regionName"] as! String)
            }
            return regions
        } else {
            return ["UK Wide"]
        }
    }

    class func getConCountInRegion(region:String, inManagedObjectContext context: NSManagedObjectContext) -> Int32
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Constituency")
        request.propertiesToFetch = ["onsid"]
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "regionName = %@", region)
        
        if let constituencies = (try? context.fetch(request)) as? [[String:AnyObject]] {
            return Int32(constituencies.count)
        }
        return 0
    }
    
    class func loadConstituency(item: (onsid:String, constituencyName:String, country:String, regionName:String, countyName: String), inManagedObjectContext context: NSManagedObjectContext) -> Constituency?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Constituency")
        request.predicate = NSPredicate(format: "onsid = %@", item.onsid)
        
        if let constituency = (try? context.fetch(request))?.first as? Constituency {
            return constituency
        } else if let constituency = NSEntityDescription.insertNewObject(forEntityName: "Constituency", into: context) as? Constituency {
            constituency.onsid = item.onsid
            constituency.constituencyName = item.constituencyName
            constituency.country = item.country
            constituency.regionName = item.regionName
            constituency.countyName = item.countyName
            return constituency
        }
        return nil
    }
    
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Constituency")
        request.includesPropertyValues = false
        
        if let constituencies = (try? context.fetch(request)) as? [Constituency] {
            for constituency in constituencies {
                context.delete(constituency)
            }
        }
    }

}
