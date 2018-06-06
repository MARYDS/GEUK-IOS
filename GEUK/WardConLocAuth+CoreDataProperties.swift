//
//  WardConLocAuth+CoreDataProperties.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import Foundation
import CoreData


extension WardConLocAuth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WardConLocAuth> {
        return NSFetchRequest<WardConLocAuth>(entityName: "WardConLocAuth");
    }

    @NSManaged public var areaId: String?
    @NSManaged public var areaName: String?
    @NSManaged public var onsid: String?
    @NSManaged public var wardId: String?
    @NSManaged public var wardName: String?

}
