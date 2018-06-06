//
//  Detail+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension Detail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Detail> {
        return NSFetchRequest<Detail>(entityName: "Detail");
    }

    @NSManaged public var change: Double
    @NSManaged public var firstName: String?
    @NSManaged public var fullName: String?
    @NSManaged public var gender: String?
    @NSManaged public var onsid: String?
    @NSManaged public var partyCode: String?
    @NSManaged public var share: Double
    @NSManaged public var surname: String?
    @NSManaged public var votes: Int32
    @NSManaged public var year: String?
    @NSManaged public var constituency: Constituency?
    @NSManaged public var election: Election?
    @NSManaged public var party: Party?
    @NSManaged public var summaryResults: Summary?

}
