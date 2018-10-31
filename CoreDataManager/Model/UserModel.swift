//
//  UserModel.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 30.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import Foundation
import CoreData

class UserModel :NSManagedObject {
    
    
    
    static let entityName = String(describing: UserModel.self)
    
    @NSManaged public var name:String
    @NSManaged public var surname:String
    @NSManaged public var id: String
    @NSManaged public var imageData: NSData
    @NSManaged public var tasks: NSSet
    
    init(imageData:NSData,name:String,surname:String,context:NSManagedObjectContext) {
        super.init(entity: UserModel.entity(), insertInto: context)
        self.name = name
        self.surname = surname
        self.imageData = imageData
        self.id =  UUID().uuidString
    }
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserModel> {
        return NSFetchRequest<UserModel>(entityName: UserModel.entityName )
    }
    
    
    
    
}
