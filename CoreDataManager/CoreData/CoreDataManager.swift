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
    case setup
    case delete
}

enum ContextType {
    case main
    case background
    case unknown
}


    

final class CoreDataManager {
    
    
    fileprivate static let containerName = "Tasks"
    fileprivate static let kPreviouslyLaunched = "previouslyLaunched"
    var batchOperation : BatchOperationManager?

    static let shared = CoreDataManager()
    var failBlock: ((ErrorModel) -> Void)? = nil
     
    //  #MARK: SETUP

    
    init() {
     //   fetchedResultsController = NSFetchedResultsController(fetchRequest: NSManagedObject.fetchRequest(), managedObjectContext: self.mainMoc, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func failure(error:ErrorModel) {
        if let theFailure = self.failBlock {
            theFailure(error)
        }
    }
    
    let previouslyLaunched =
        UserDefaults.standard.bool(forKey: CoreDataManager.kPreviouslyLaunched)
    
    
    var modelUrl :URL {
        if #available(iOS 10.0, *) {
            let url = self.applicationDocumentsDirectory.appendingPathComponent("\(CoreDataManager.containerName).sqlite")
            return url
        }
        return  Bundle.main.url(forResource: CoreDataManager.containerName, withExtension: "momd")!
    }
 
    lazy var persistentContainer: NSPersistentContainer? = {
        if #available(iOS 10.0, *) {
            var container = NSPersistentContainer(name: CoreDataManager.containerName)
           // self.seedCoreDataContainerIfFirstLaunch()
            let description = NSPersistentStoreDescription(url: modelUrl)
            description.shouldInferMappingModelAutomatically = true
            description.shouldMigrateStoreAutomatically = true
            container.persistentStoreDescriptions = [description]
            
            container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
                if let error = error as NSError? {
                    NSLog("CoreData error \(error), \(error._userInfo)")
                    self?.failure(error: ErrorModel.init(error: error))
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
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreUrl, options: [NSMigratePersistentStoresAutomaticallyOption:true,NSInferMappingModelAutomaticallyOption:true])
        }
        catch {
               self?.failure(error: ErrorModel.init(error: DataAccessError.setup))
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
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
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
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
    
   
    func saveContext(type: ContextType) throws {
        if #available(iOS 10.0, *) {
            if let context = type == .main ? mainMoc : privateMoc {
                if context.hasChanges {
                    do {
                        try context.save()
                    }
                    catch {
                        throw DataAccessError.saveContext
            }
                }
            }
        }
           else {
            if privateMoc!.hasChanges {
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
    
    func fetchListAsync<T:NSManagedObject>(_ objectType: T.Type,predicateFormatter:PredicateFormatter? = nil, completion: @escaping (_ result:Any) -> ())  {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicateFormatter?.predicate
        
          let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) {   (result) in
                guard let result = result.finalResult as? [T] else {
                    completion(ErrorModel.init(message:"bad fetch from core data"))
                    return
                }
                completion(result)
        }
        do {
            try self.privateMoc!.execute(asyncFetchRequest)
        }
        catch {
            completion(ErrorModel.init(message:"bad fetch from core data"))
        }
        }
    
    
    func delete<T:NSManagedObject>(_ object: T) {
        privateMoc?.delete(object)
      try? self.saveContext(type: .background)
    }
    
   
    #warning("It is ios8 or higher ")
    func updateWithBatch<T:NSManagedObject>(_ objectType: T.Type,predicateFormat:PredicateFormatter,updateTo properties:[String:Any]) throws  {
        let entityName = String(describing: objectType)
        //batchOperation = BatchOperationManager(entityName: entityName, batchType: .update, predicate: predicateFormat, propertiesToUpdate: properties)
        //batchOperation = BatchOperationManager(entityName: entityName)
        let request:NSBatchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
        request.propertiesToUpdate = properties
        request.predicate = predicateFormat.predicate
        let resultType:NSBatchUpdateRequestResultType = .updatedObjectIDsResultType
        request.resultType = resultType

        persistentContainer?.performBackgroundTask({ [weak self]  (privateMoc) in
             do {
                if let result = try privateMoc.execute(request) as? NSBatchUpdateResult {
                    guard let objectIDs = result.result as? [NSManagedObjectID] else {
                        self?.failure(error: ErrorModel.init(error: DataAccessError.update))
                        return
                    }
                    let changes = [NSUpdatedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [(self?.mainMoc)!])
                }
            }
            catch{
               self?.failure(error: ErrorModel.init(error: DataAccessError.update))
            }
        })
    }
    
    func deleteWithBatch<T:NSManagedObject>(_ objectType:T.Type,predicateFormat:PredicateFormatter? = nil) throws {
        let entityName = String(describing: objectType)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        if predicateFormat != nil {
            if let predicate = predicateFormat?.predicate {
            request.predicate = predicate
        }
        }
        //batchOperation = BatchOperationManager(entityName: entityName, batchType: .delete , predicate: predicateFormat)
        if #available(iOS 10.0, *) {
           persistentContainer?.performBackgroundTask({ [weak self]  (privateMoc) in
        do {
            let result = try privateMoc.execute(deleteRequest) as? NSBatchDeleteResult
            guard let objectIDs = result?.result as? [NSManagedObjectID] else {
                self?.failure(error: ErrorModel.init(error: DataAccessError.delete))
                return
            }
            
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [(self?.mainMoc)!])
        }
            catch {
            self?.failure(error: ErrorModel.init(error: DataAccessError.delete))
            }
              return
            })
    }
      
        if #available(iOS 9.0, *) {
            let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            do {
                let result = try privateMoc!.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
                objectIDs.forEach { objectID in
                 let eachObj = mainMoc.object(with: objectID)
                    mainMoc.refresh(eachObj, mergeChanges: false)
                }
            } catch {
            self.failure(error: ErrorModel.init(error: DataAccessError.delete))
            }
        }
             if #available(iOS 8.0, *) {
                //TODO:ios8.0 and lower
        }
      }
     }
    
    
private extension CoreDataManager {
    func seedCoreDataContainerIfFirstLaunch() {
        
        if !previouslyLaunched {
            UserDefaults.standard.set(true,forKey:CoreDataManager.kPreviouslyLaunched)
            let url = self.modelUrl
            let seededDatabaseURL = Bundle.main.url(forResource: CoreDataManager.containerName, withExtension: "sqlite")!
            _ = try? FileManager.default.removeItem(at: url)
            do {
                try FileManager.default.copyItem(at: seededDatabaseURL, to: url)
            }
            catch let error as Error {
                self.failure(error: ErrorModel.init(error: error))
            }
            let seededSHMURL = Bundle.main.url(forResource: CoreDataManager.containerName, withExtension: ".sqlite-shm")!
            let shmURL = applicationDocumentsDirectory.appendingPathComponent("\(CoreDataManager.containerName).sqlite-shm")
            _ = try? FileManager.default.removeItem(at: shmURL)
            do {
                try FileManager.default.copyItem(at: seededSHMURL, to: shmURL)
            }
            catch let error as Error {
                self.failure(error: ErrorModel.init(error: error))
            }
            
            let seededWALURL = Bundle.main.url(forResource: CoreDataManager.containerName, withExtension: ".sqlite-wal")!
            let walURL = applicationDocumentsDirectory.appendingPathComponent("\(CoreDataManager.containerName).sqlite-wal")
            _ = try? FileManager.default.removeItem(at: walURL)
            do {
                try FileManager.default.copyItem(at: seededWALURL, to: walURL)
            }
            catch let error as Error {
                self.failure(error: ErrorModel.init(error: error))
            }
            
        }
        
        
    }
    
}



