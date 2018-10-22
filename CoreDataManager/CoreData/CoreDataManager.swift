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

enum ContextType {
    case main
    case background
    case unknown
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
           let moc = persistentContainer?.newBackgroundContext()
            return moc
        }
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = self.mainMoc
        return moc
    }()
    
    private lazy var applicationDocumentsDirectory:URL = {
        return  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
  
    
   
    func saveContext(type: ContextType) throws {
           if #available(iOS 10.0, *) {
        if let context = type == .main ? mainMoc : privateMoc {
         if context.hasChanges {
                    do {
                        try context.save()
                    }
                    catch{}
                }
            }
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
        /*
         persistentContainer?.performBackgroundTask({ (moc) in
         do{
         try moc.save()
         }
         catch{}
         })
         }
         */
    }
    
    
    // Synchronous & Asynchronous request times with 800 affected rows on iPhone 6
    // async->fetch->35ms , update->25ms , delete 19ms
    // sync->fetch->20ms , update->80ms , delete 57ms
    
    
    func fetchList<T:NSManagedObject>(_ objectType: T.Type) throws -> [T]  {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
     do {
            if let fetchedObjects = try privateMoc?.fetch(fetchRequest) as? [T] {
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
    
    
    // fetchRequest.fetchLimit = 20
    // fetchRequest.fetchOffset = fetchOffSet
    //fetchRequest.predicate = batchOperation?.predicateFormatter?.predicate
    
    
    
    func fetchListAsync<T:NSManagedObject>(_ objectType: T.Type, completion: @escaping (_ result:Any) -> ())  {
        
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            guard let result = result.finalResult as? [T] else {
                completion(ErrorModel.init(message:"bad fetch from core data"))
                return
            }
           completion(result)
        }
        do {
            try privateMoc?.execute(asyncFetchRequest)
        }
        catch {
          completion(ErrorModel.init(message:"bad fetch from core data"))
        }
    }
    
    func updateWithBatch<T:NSManagedObject>(_ objectType: T.Type) throws  {
        let entityName = String(describing: objectType)
        //batchOperation = BatchOperationManager(entityName: entityName)
        let request:NSBatchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
        request.propertiesToUpdate = [ "name" : "task132131" ]
        request.predicate = NSPredicate(format: "name == %@","task1")
        let resultType:NSBatchUpdateRequestResultType = .updatedObjectIDsResultType
            request.resultType = resultType
        persistentContainer?.performBackgroundTask({ (privateMoc) in
             do {
                if let result = try privateMoc.execute(request) as? NSBatchUpdateResult {
                    guard let objectIDs = result.result as? [NSManagedObjectID] else { return
                        #warning("TODO:handle error")
                    }
                    let changes = [NSUpdatedObjectsKey: objectIDs]
                   NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.mainMoc])
                }
            }
            catch{
               #warning("TODO:handle error")
            }
            
        })
    }
    
    func deleteWithBatch<T:NSManagedObject>(_ objectType:T.Type) throws {
            persistentContainer?.performBackgroundTask({ (privateMoc) in
                
        let entityName = String(describing: objectType)
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let predicate = NSPredicate(format: "name == %@","task1")
        request.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
         deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try privateMoc.execute(deleteRequest) as? NSBatchDeleteResult
            guard let objectIDs = result?.result as? [NSManagedObjectID] else {
                return
                
            }
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.mainMoc])
        }
        catch {
            
                }
            })
    }
}


