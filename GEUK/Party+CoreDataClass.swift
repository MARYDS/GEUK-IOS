//
//  Party+CoreDataClass.swift
//  GEUK_T1
//
//  Created by Mary Forde on 24/11/2016.
//  Copyright © 2016 Mary Forde. All rights reserved.
//

import Foundation
import CoreData

@objc(Party)
public class Party: NSManagedObject {

    // Return details for a party
    class func getParty(partyCode:String, inManagedObjectContext context: NSManagedObjectContext) -> Party? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Party")
        request.predicate = NSPredicate(format: "partyCode = %@", partyCode)
        if let party = (try? context.fetch(request))?.first as? Party {
            return party
        }  else {
            return nil
        }
    }
    
    class func loadParty(item: (partyCode:String, name:String, colour:String), inManagedObjectContext context: NSManagedObjectContext) -> Party?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Party")
        request.predicate = NSPredicate(format: "partyCode = %@", item.partyCode)
        
        if let party = (try? context.fetch(request))?.first as? Party {
            return party
        } else if let party = NSEntityDescription.insertNewObject(forEntityName: "Party", into: context) as? Party {
            party.partyCode = item.partyCode
            party.name = item.name
            party.colour = item.colour
            return party
        }
        return nil
    }
    
    class func removeData (inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Party")
        request.includesPropertyValues = false
        
        if let parties = (try? context.fetch(request)) as? [Party] {
            for party in parties {
                context.delete(party)
            }
        }
    }

}
