//
//  SimPartyConstituencies+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension SimPartyConstituencies {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SimPartyConstituencies> {
        return NSFetchRequest<SimPartyConstituencies>(entityName: "SimPartyConstituencies");
    }

    @NSManaged public var constituencyCount: Int32
    @NSManaged public var electorate: Int32
    @NSManaged public var partyFrom: String?
    @NSManaged public var partyFromVotes: Int32
    @NSManaged public var partyTo: String?
    @NSManaged public var partyToVotes: Int32
    @NSManaged public var regionName: String?
    @NSManaged public var year: String?
    @NSManaged public var from: Party?
    @NSManaged public var to: Party?

}
