//
//  Simulation+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension Simulation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Simulation> {
        return NSFetchRequest<Simulation>(entityName: "Simulation");
    }

    @NSManaged public var changePercent: Double
    @NSManaged public var fromPartyCode: String?
    @NSManaged public var regionName: String?
    @NSManaged public var toPartyCode: String?
    @NSManaged public var year: String?
    @NSManaged public var fromParty: Party?
    @NSManaged public var toParty: Party?

}
