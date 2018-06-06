//
//  Constituency+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension Constituency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Constituency> {
        return NSFetchRequest<Constituency>(entityName: "Constituency");
    }

    @NSManaged public var constituencyName: String?
    @NSManaged public var country: String?
    @NSManaged public var countyName: String?
    @NSManaged public var onsid: String?
    @NSManaged public var regionName: String?
    @NSManaged public var detailResults: NSSet?
    @NSManaged public var localAuthority: NSSet?
    @NSManaged public var summaryResults: NSSet?

}

// MARK: Generated accessors for detailResults
extension Constituency {

    @objc(addDetailResultsObject:)
    @NSManaged public func addToDetailResults(_ value: Detail)

    @objc(removeDetailResultsObject:)
    @NSManaged public func removeFromDetailResults(_ value: Detail)

    @objc(addDetailResults:)
    @NSManaged public func addToDetailResults(_ values: NSSet)

    @objc(removeDetailResults:)
    @NSManaged public func removeFromDetailResults(_ values: NSSet)

}

// MARK: Generated accessors for localAuthority
extension Constituency {

    @objc(addLocalAuthorityObject:)
    @NSManaged public func addToLocalAuthority(_ value: ConstituencyLocAuth)

    @objc(removeLocalAuthorityObject:)
    @NSManaged public func removeFromLocalAuthority(_ value: ConstituencyLocAuth)

    @objc(addLocalAuthority:)
    @NSManaged public func addToLocalAuthority(_ values: NSSet)

    @objc(removeLocalAuthority:)
    @NSManaged public func removeFromLocalAuthority(_ values: NSSet)

}

// MARK: Generated accessors for summaryResults
extension Constituency {

    @objc(addSummaryResultsObject:)
    @NSManaged public func addToSummaryResults(_ value: Summary)

    @objc(removeSummaryResultsObject:)
    @NSManaged public func removeFromSummaryResults(_ value: Summary)

    @objc(addSummaryResults:)
    @NSManaged public func addToSummaryResults(_ values: NSSet)

    @objc(removeSummaryResults:)
    @NSManaged public func removeFromSummaryResults(_ values: NSSet)

}
