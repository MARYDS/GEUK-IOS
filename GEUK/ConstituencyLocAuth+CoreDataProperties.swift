//
//  ConstituencyLocAuth+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension ConstituencyLocAuth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConstituencyLocAuth> {
        return NSFetchRequest<ConstituencyLocAuth>(entityName: "ConstituencyLocAuth");
    }

    @NSManaged public var areaCode: String?
    @NSManaged public var onsid: String?
    @NSManaged public var wardsCon: Int32
    @NSManaged public var wardsLA: Int32
    @NSManaged public var constituency: Constituency?
    @NSManaged public var referendum: EUReferendum?

}
