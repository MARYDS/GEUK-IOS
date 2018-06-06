//
//  EUReferendum+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension EUReferendum {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EUReferendum> {
        return NSFetchRequest<EUReferendum>(entityName: "EUReferendum");
    }

    @NSManaged public var areaCode: String?
    @NSManaged public var areaName: String?
    @NSManaged public var electorate: Int32
    @NSManaged public var leavePercent: Double
    @NSManaged public var leaveVotes: Int32
    @NSManaged public var region: String?
    @NSManaged public var remainPercent: Double
    @NSManaged public var remainVotes: Int32
    @NSManaged public var turnoutPercent: Double
    @NSManaged public var constituencies: NSSet?

}

// MARK: Generated accessors for constituencies
extension EUReferendum {

    @objc(addConstituenciesObject:)
    @NSManaged public func addToConstituencies(_ value: ConstituencyLocAuth)

    @objc(removeConstituenciesObject:)
    @NSManaged public func removeFromConstituencies(_ value: ConstituencyLocAuth)

    @objc(addConstituencies:)
    @NSManaged public func addToConstituencies(_ values: NSSet)

    @objc(removeConstituencies:)
    @NSManaged public func removeFromConstituencies(_ values: NSSet)

}
