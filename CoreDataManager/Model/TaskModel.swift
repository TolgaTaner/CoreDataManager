//
//  TaskModel.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 19.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import Foundation
import CoreData

class TaskModel :NSManagedObject {
    
   
    static let entityName = String(describing: TaskModel.self)
    
    @NSManaged public var name:String
    @NSManaged public var id: String
   
    
    convenience init(name:String,manager:CoreDataManager) {
        let entity = NSEntityDescription.entity(forEntityName: TaskModel.entityName , in: (manager.persistentContainer?.viewContext)!)
        self.init(entity: entity!, insertInto: manager.persistentContainer?.viewContext)
        self.name = name
        self.id =  UUID().uuidString
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskModel> {
        return NSFetchRequest<TaskModel>(entityName: TaskModel.entityName )
    }

    
}
