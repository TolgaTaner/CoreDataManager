//
//  CoreDataManager.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 18.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//


import Foundation
import CoreData

enum DataAccessError: Error {
    case fetch
    case create
    case saveContext
    case wrongEntityDescription
    case update
}


final class CoreDataManager {
    
    #warning("TODO:Change it with your container name.")
    static let containerName = "Tasks"
    var batchOperation : BatchOperationManager?
      
    init() {
        
    }
    
    init(batchOperation:BatchOperationManager) {
        self.batchOperation = batchOperation
    }
    /*
     if #available(iOS 10.0, *) {
     let privateManagedObjectContext = persistentContainer.newBackgroundContext()
     }
     */
    
    /*
     ios8+
     let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
     privateManagedObjectContext.parent = mainManagedObjectContext
     iOS 10+
     
     let privateManagedObjectContext = persistentContainer.newBackgroundContext()
     
     var context: NSManagedObjectContext {
     mutating get {
     if #available(iOS 10.0, *) {
     return persistentContainer.viewContext
     } else {
     return managedObjectContext
     }
     }
     }
     */
    
    
    var modelUrl :URL {
        return  Bundle.main.url(forResource: CoreDataManager.containerName, withExtension: "momd")!
    }
 
    lazy var persistentContainer: NSPersistentContainer? = {
        if #available(iOS 10.0, *) {
            var container = NSPersistentContainer(name: CoreDataManager.containerName)
           // let description = NSPersistentStoreDescription(url: modelUrl)
           // container.persistentStoreDescriptions = [description]
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
                print(storeDescription.url!.absoluteString)
            })
            return container
        }
        return nil
    }()
    
    
    lazy var persistentStoreCoordinator:NSPersistentStoreCoordinator? = {
        if #available(iOS 10.0, *) {
            return nil
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel!)
        let persistentStoreUrl = self.applicationDocumentsDirectory.appendingPathComponent("\(CoreDataManager.containerName).sqlite")
        
        DispatchQueue.global(qos: .background).async {
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreUrl, options: [NSMigratePersistentStoresAutomaticallyOption:true,NSInferMappingModelAutomaticallyOption:true])
        }
        catch {
            #warning("TODO:Configured coordinator error")
        }
        }
        return coordinator
    }()
    
    lazy var managedObjectModel : NSManagedObjectModel? = {
        if #available(iOS 10.0, *) {
            return nil
        }
        return NSManagedObjectModel(contentsOf: modelUrl)!
    }()
    
    
    lazy var mainMoc :NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return persistentContainer?.viewContext ??  NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
        
    }()
    
    
    lazy var privateMoc:NSManagedObjectContext? = {
        if #available(iOS 10.0, *) {
           // let moc = persistentContainer?.newBackgroundContext() ?? NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            return nil
        }
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = self.mainMoc
        return moc
    }()
    
    private lazy var applicationDocumentsDirectory:URL = {
        return  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
  
    
    
    func saveContext () throws {
        if #available(iOS 10.0, *) {
             persistentContainer?.performBackgroundTask({ (moc) in
                    do{
                        try moc.save()
                    }
                    catch{}
                })
            }
        else {
            
            privateMoc!.perform {
                print("private moc ios8 and lower saved successfully")
                do{
                    try self.privateMoc!.save()
                }
                catch{}
                self.mainMoc.performAndWait {
                    do {
                        print("main moc ios8 and lower saved successfully")
                        try self.mainMoc.save()
                    }
                    catch{}
                }
            }
        }
    }
    
    
    func fetchList<T:NSManagedObject>(_ objectType: T.Type) throws -> [T]  {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = batchOperation?.predicateFormatter?.predicate
        do {
            if let fetchedObjects = try mainMoc.fetch(fetchRequest) as? [T] {
                return fetchedObjects
            }
            else {
                throw DataAccessError.fetch
            }
            
        }
        catch {
            throw DataAccessError.fetch
        }
    }
    
    
    func fetchListAsync<T:NSManagedObject>(_ objectType: T.Type, fetchOffSet:Int = 0, completion: @escaping (_ result:Any) -> ())  {
        
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.fetchLimit = 20
        fetchRequest.fetchOffset = fetchOffSet
        fetchRequest.predicate = batchOperation?.predicateFormatter?.predicate
        
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            guard let result = result.finalResult as? [T] else {
                completion(ErrorModel.init(message:"bad fetch from core data"))
                return
            }
           completion(result)
        }
        do {
            try mainMoc.execute(asyncFetchRequest)
        }
        catch {
          completion(ErrorModel.init(message:"bad fetch from core data"))
        }
    }
    
    func updateWithBatch<T:NSManagedObject>(_ objectType: T.Type) throws  {
        let entityName = String(describing: objectType)
        batchOperation = BatchOperationManager(entityName: entityName)
        do {
            if let result = try  mainMoc.execute((batchOperation?.request)!) as? NSBatchUpdateResult {
                print(result.result)
            }
        }
        catch{
            throw DataAccessError.update
        }
    }
    
    
    
    
}
