//
//  TaskModel.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 19.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import Foundation
import CoreData

class TaskModel:NSManagedObject {
    
    let name:String = ""
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: Dictionary<String, Any>){
        let context = CoreDataManager.shared.privateMoc
        let entity = NSEntityDescription.entity(forEntityName: PhotoModel.entityName , in: context)
        super.init(entity: entity!, insertInto: context)
        self.id = dictionary[PhotoModel.kId] as? String ?? ""
        self.owner = dictionary[PhotoModel.kOwner] as? String ?? ""
        self.secret = dictionary[PhotoModel.kSecret] as? String ?? ""
        self.server = dictionary[PhotoModel.kServer] as? String ?? ""
        self.farm  = Int32(dictionary[PhotoModel.kFarm] as? Int ?? 0)
        self.title  = dictionary[PhotoModel.kTitle] as? String ?? ""
        self.imageUrlPath = "https://farm\(self.farm).staticflickr.com/\(self.server)/\(self.id)_\(self.secret).jpg"
        
    }
    
    
    
    
}
