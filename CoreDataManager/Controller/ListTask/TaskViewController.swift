//
//  TaskViewController.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 20.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {

    
    @IBOutlet weak var tasksTableView: TasksTableView!
    var coreDataManager:CoreDataManager?
    var taskNavigationController:TaskNavigationController?
    var taskList : [TaskModel] = [] {
        didSet{
            tasksTableView?.tasks = taskList
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        if let navigation = self.navigationController as? TaskNavigationController {
            self.taskNavigationController = navigation
            self.taskNavigationController?.actionDelegate = self
        }
    //      let predicate = PredicateFormatter(key: "key", value: "value", formatType: .greaterThanEqual)
    //    let batch = BatchOperationManager(entityName: "entity", predicateFormatter: predicate)
         coreDataManager = CoreDataManager()
        fetchTask()
    }
    
    func fetchTask() {
        coreDataManager!.fetchListAsync(TaskModel.self) { [weak self]  (result) in
            if let taskList = result as? [TaskModel] {
                self?.taskList = taskList
            }
            else if let error = result as? ErrorModel {
                print(error.message)
            }
        }
    }
    
    func updateTask() {
        do {
            let predicate = PredicateFormatter(key: "name", value: "ExampleTask", formatType: .keyValueObserving)
            let updateTo = [ "name" : "changedTask" ]
            try coreDataManager?.updateWithBatch(TaskModel.self, predicateFormat: predicate, updateTo: updateTo)
        }
        catch {
        }
    }
    
    func deleteTask() {
        do {
            let predicate = PredicateFormatter(key: "name", value: "ExampleTask", formatType: .keyValueObserving)
            try coreDataManager?.deleteWithBatch(TaskModel.self, predicateFormat: predicate)
        }
        catch {
        }
    }
}

extension TaskViewController : TaskNavigationControllerDelegate {
    func addButtonTapped() {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTaskViewController") as? AddTaskViewController {
            controller.actionDelegate = self
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
    }
}
extension TaskViewController:AddTaskViewControllerDelegate {
    func pop(_ taskName: String) {
        let addedTask :TaskModel = TaskModel(name: taskName, context: (coreDataManager?.privateMoc)!)
      do {
        try? coreDataManager?.saveContext(type: .background)
        
        }
        
      
    }
}
