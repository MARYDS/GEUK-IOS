//
//  Party+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension Party {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Party> {
        return NSFetchRequest<Party>(entityName: "Party");
    }

    @NSManaged public var colour: String?
    @NSManaged public var name: String?
    @NSManaged public var partyCode: String?
    @NSManaged public var detailResults: NSSet?
    @NSManaged public var fromSim: NSSet?
    @NSManaged public var partySummary: NSSet?
    @NSManaged public var simFrom: NSSet?
    @NSManaged public var simTo: NSSet?
    @NSManaged public var summaryPrev: NSSet?
    @NSManaged public var summaryResults: NSSet?
    @NSManaged public var summaryrunnerup: NSSet?
    @NSManaged public var toSim: NSSet?

}

// MARK: Generated accessors for detailResults
extension Party {

    @objc(addDetailResultsObject:)
    @NSManaged public func addToDetailResults(_ value: Detail)

    @objc(removeDetailResultsObject:)
    @NSManaged public func removeFromDetailResults(_ value: Detail)

    @objc(addDetailResults:)
    @NSManaged public func addToDetailResults(_ values: NSSet)

    @objc(removeDetailResults:)
    @NSManaged public func removeFromDetailResults(_ values: NSSet)

}

// MARK: Generated accessors for fromSim
extension Party {

    @objc(addFromSimObject:)
    @NSManaged public func addToFromSim(_ value: Simulation)

    @objc(removeFromSimObject:)
    @NSManaged public func removeFromFromSim(_ value: Simulation)

    @objc(addFromSim:)
    @NSManaged public func addToFromSim(_ values: NSSet)

    @objc(removeFromSim:)
    @NSManaged public func removeFromFromSim(_ values: NSSet)

}

// MARK: Generated accessors for partySummary
extension Party {

    @objc(addPartySummaryObject:)
    @NSManaged public func addToPartySummary(_ value: PartySummary)

    @objc(removePartySummaryObject:)
    @NSManaged public func removeFromPartySummary(_ value: PartySummary)

    @objc(addPartySummary:)
    @NSManaged public func addToPartySummary(_ values: NSSet)

    @objc(removePartySummary:)
    @NSManaged public func removeFromPartySummary(_ values: NSSet)

}

// MARK: Generated accessors for simFrom
extension Party {

    @objc(addSimFromObject:)
    @NSManaged public func addToSimFrom(_ value: SimPartyConstituencies)

    @objc(removeSimFromObject:)
    @NSManaged public func removeFromSimFrom(_ value: SimPartyConstituencies)

    @objc(addSimFrom:)
    @NSManaged public func addToSimFrom(_ values: NSSet)

    @objc(removeSimFrom:)
    @NSManaged public func removeFromSimFrom(_ values: NSSet)

}

// MARK: Generated accessors for simTo
extension Party {

    @objc(addSimToObject:)
    @NSManaged public func addToSimTo(_ value: SimPartyConstituencies)

    @objc(removeSimToObject:)
    @NSManaged public func removeFromSimTo(_ value: SimPartyConstituencies)

    @objc(addSimTo:)
    @NSManaged public func addToSimTo(_ values: NSSet)

    @objc(removeSimTo:)
    @NSManaged public func removeFromSimTo(_ values: NSSet)

}

// MARK: Generated accessors for summaryPrev
extension Party {

    @objc(addSummaryPrevObject:)
    @NSManaged public func addToSummaryPrev(_ value: Summary)

    @objc(removeSummaryPrevObject:)
    @NSManaged public func removeFromSummaryPrev(_ value: Summary)

    @objc(addSummaryPrev:)
    @NSManaged public func addToSummaryPrev(_ values: NSSet)

    @objc(removeSummaryPrev:)
    @NSManaged public func removeFromSummaryPrev(_ values: NSSet)

}

// MARK: Generated accessors for summaryResults
extension Party {

    @objc(addSummaryResultsObject:)
    @NSManaged public func addToSummaryResults(_ value: Summary)

    @objc(removeSummaryResultsObject:)
    @NSManaged public func removeFromSummaryResults(_ value: Summary)

    @objc(addSummaryResults:)
    @NSManaged public func addToSummaryResults(_ values: NSSet)

    @objc(removeSummaryResults:)
    @NSManaged public func removeFromSummaryResults(_ values: NSSet)

}

// MARK: Generated accessors for summaryrunnerup
extension Party {

    @objc(addSummaryrunnerupObject:)
    @NSManaged public func addToSummaryrunnerup(_ value: Summary)

    @objc(removeSummaryrunnerupObject:)
    @NSManaged public func removeFromSummaryrunnerup(_ value: Summary)

    @objc(addSummaryrunnerup:)
    @NSManaged public func addToSummaryrunnerup(_ values: NSSet)

    @objc(removeSummaryrunnerup:)
    @NSManaged public func removeFromSummaryrunnerup(_ values: NSSet)

}

// MARK: Generated accessors for toSim
extension Party {

    @objc(addToSimObject:)
    @NSManaged public func addToToSim(_ value: Simulation)

    @objc(removeToSimObject:)
    @NSManaged public func removeFromToSim(_ value: Simulation)

    @objc(addToSim:)
    @NSManaged public func addToToSim(_ values: NSSet)

    @objc(removeToSim:)
    @NSManaged public func removeFromToSim(_ values: NSSet)

}
