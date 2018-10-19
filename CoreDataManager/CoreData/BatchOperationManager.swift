//
//  BatchOperationManager.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 19.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import Foundation
import CoreData

/*TODO:will be updated
 enum BatchType {
 case delete
 case update
 }
 */

class BatchOperationManager :NSObject {
    
    lazy var properties:[String:Any] = [String:Any]()
    var predicateFormatter : PredicateFormatter?
    var request:NSBatchUpdateRequest?
    var resultType:NSBatchUpdateRequestResultType = .statusOnlyResultType
    
    /*
     
     case statusOnlyResultType // Return a status boolean
     
     case updatedObjectIDsResultType // Return the object IDs of the rows that were updated
     
     case updatedObjectsCountResultType // Return the number of rows that were updated
     */
    
    init(entityName:String) {
        request = NSBatchUpdateRequest(entityName: entityName)
    }
    init(entityName:String,predicateFormatter:PredicateFormatter) {
        request = NSBatchUpdateRequest(entityName: entityName)
        self.predicateFormatter = predicateFormatter
    }
    func setPropertyToUpdate(_ key:String, value:Any) {
        properties.updateValue(value, forKey: key)
    }
    func setPropertiesToUpdate(dictionary:[String:Any]) {
        self.properties =  properties.merging(dictionary, uniquingKeysWith: { (first, _) in first })
    }
    
}
