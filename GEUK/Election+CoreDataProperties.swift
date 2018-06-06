//
//  Election+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension Election {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Election> {
        return NSFetchRequest<Election>(entityName: "Election");
    }

    @NSManaged public var electorate: Int32
    @NSManaged public var invalidVotes: Int32
    @NSManaged public var turnoutPercent: Double
    @NSManaged public var validVotes: Int32
    @NSManaged public var year: String?
    @NSManaged public var detailResults: NSSet?
    @NSManaged public var summaryResults: NSSet?

}

// MARK: Generated accessors for detailResults
extension Election {

    @objc(addDetailResultsObject:)
    @NSManaged public func addToDetailResults(_ value: Detail)

    @objc(removeDetailResultsObject:)
    @NSManaged public func removeFromDetailResults(_ value: Detail)

    @objc(addDetailResults:)
    @NSManaged public func addToDetailResults(_ values: NSSet)

    @objc(removeDetailResults:)
    @NSManaged public func removeFromDetailResults(_ values: NSSet)

}

// MARK: Generated accessors for summaryResults
extension Election {

    @objc(addSummaryResultsObject:)
    @NSManaged public func addToSummaryResults(_ value: Summary)

    @objc(removeSummaryResultsObject:)
    @NSManaged public func removeFromSummaryResults(_ value: Summary)

    @objc(addSummaryResults:)
    @NSManaged public func addToSummaryResults(_ values: NSSet)

    @objc(removeSummaryResults:)
    @NSManaged public func removeFromSummaryResults(_ values: NSSet)

}
