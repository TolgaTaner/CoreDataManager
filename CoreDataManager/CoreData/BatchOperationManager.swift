//
//  BatchOperationManager.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 19.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import Foundation
import CoreData


 enum BatchType {
 case delete
 case update
 case unknown
 }


class BatchOperationManager :NSObject {
    
    
    
    var properties:[String:Any]?
    var predicateFormatter : PredicateFormatter?
    var updateRequest:NSBatchUpdateRequest? = nil
    var deleteRequest :NSBatchDeleteRequest? = nil
    var type:BatchType = .unknown
    /*
     
     case statusOnlyResultType // Return a status boolean
     
     case updatedObjectIDsResultType // Return the object IDs of the rows that were updated
     
     case updatedObjectsCountResultType // Return the number of rows that were updated
     */
    
    init(entityName:String,batchType:BatchType,predicate:PredicateFormatter,propertiesToUpdate:[String:Any] = [:] ) {
        self.type = batchType
        self.predicateFormatter = predicate
        if type == .delete {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            self.deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            self.deleteRequest!.resultType = .resultTypeObjectIDs
            request.predicate = self.predicateFormatter?.predicate
            
        }
       else  if type == .update {
            self.properties = propertiesToUpdate
              self.updateRequest = NSBatchUpdateRequest(entityName: entityName)
             self.updateRequest?.resultType = .updatedObjectIDsResultType
            updateRequest?.predicate = self.predicateFormatter?.predicate
        }
    }
    
    init(entityName:String,predicateFormatter:PredicateFormatter) {
        updateRequest = NSBatchUpdateRequest(entityName: entityName)
        self.predicateFormatter = predicateFormatter
    }
    
    func setPropertyToUpdate(_ key:String, value:Any) {
        properties?.updateValue(value, forKey: key)
    }
    func setPropertiesToUpdate(dictionary:[String:Any]) {
        self.properties =  properties?.merging(dictionary, uniquingKeysWith: { (first, _) in first })
    }
    
}
