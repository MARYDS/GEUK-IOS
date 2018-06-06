//
//  PartySummary+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension PartySummary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PartySummary> {
        return NSFetchRequest<PartySummary>(entityName: "PartySummary");
    }

    @NSManaged public var candidates: Int32
    @NSManaged public var changePercent: Double
    @NSManaged public var partyCode: String?
    @NSManaged public var regionName: String?
    @NSManaged public var seats: Int32
    @NSManaged public var votes: Int32
    @NSManaged public var votesPercent: Double
    @NSManaged public var year: String?
    @NSManaged public var party: Party?

}
