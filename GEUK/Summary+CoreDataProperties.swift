//
//  Summary+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension Summary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Summary> {
        return NSFetchRequest<Summary>(entityName: "Summary");
    }

    @NSManaged public var electorate: Int32
    @NSManaged public var firstName: String?
    @NSManaged public var fullName: String?
    @NSManaged public var invalidVotes: Int32
    @NSManaged public var majority: Int32
    @NSManaged public var majorityPercent: Double
    @NSManaged public var narrative: String?
    @NSManaged public var onsid: String?
    @NSManaged public var partyChanged: String?
    @NSManaged public var partyCode: String?
    @NSManaged public var previousParty: String?
    @NSManaged public var runnerUp: String?
    @NSManaged public var surname: String?
    @NSManaged public var validVotes: Int32
    @NSManaged public var year: String?
    @NSManaged public var constituency: Constituency?
    @NSManaged public var detailResults: NSSet?
    @NSManaged public var election: Election?
    @NSManaged public var party: Party?
    @NSManaged public var prevParty: Party?
    @NSManaged public var runnerupparty: Party?

}

// MARK: Generated accessors for detailResults
extension Summary {

    @objc(addDetailResultsObject:)
    @NSManaged public func addToDetailResults(_ value: Detail)

    @objc(removeDetailResultsObject:)
    @NSManaged public func removeFromDetailResults(_ value: Detail)

    @objc(addDetailResults:)
    @NSManaged public func addToDetailResults(_ values: NSSet)

    @objc(removeDetailResults:)
    @NSManaged public func removeFromDetailResults(_ values: NSSet)

}
