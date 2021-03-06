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
    
    var taskNavigationController:TaskNavigationController?
    var coreDataManager: CoreDataManager? 
    var taskList : [TaskModel] = [] {
        didSet{
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
        tasksTableView.actionDelegate = self 
     fetchTask()
    }
    
    func fetchTask() {
        coreDataManager?.fetchListAsync(TaskModel.self) { [weak self]  (result) in
            if let taskList = result as? [TaskModel] {
                
                DispatchQueue.main.async {
                    self?.tasksTableView?.tasks = taskList
                    self?.tasksTableView.reloadData()
                    
                }
            }
            else if let error = result as? ErrorModel {
                print(error.message)
            }
        }
    }
  
    /*
    func updateTask() {
        do {
            let predicate = PredicateFormatter(key: "name", value: "ExampleTask", formatType: .keyValueObserving)
            let updateTo = [ "name" : "changedTask" ]
            try CoreDataManager.shared.updateWithBatch(TaskModel.self, predicateFormat: predicate, updateTo: updateTo)
        }
        catch {
        }
    }
 */
    
    func deleteAllTask() {
        do {
            try coreDataManager?.deleteWithBatch(TaskModel.self)
            self.tasksTableView.reloadData()
        }
        catch let err {
            print(err)
        }
    }
 
    
    
}

extension TaskViewController : TaskNavigationControllerDelegate {
    func deleteAllButtonTapped() {
        self.tasksTableView.tasks.removeAll()
        deleteAllTask()
    }
    
    func addButtonTapped() {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTaskViewController") as? AddTaskViewController {
            controller.actionDelegate = self
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
    }
}
extension TaskViewController:AddTaskViewControllerDelegate {
    func pop(_ taskName: String) {
        for _ in 0..<10 {
            let addedTask :TaskModel = TaskModel(name: taskName, context: (coreDataManager?.privateMoc!)!)
                self.tasksTableView?.tasks.append(addedTask)
        }
        
      do {
        try? coreDataManager?.saveContext(type: .background)
       self.tasksTableView.reloadData()
        }
    }
}

extension TaskViewController:TasksTableViewDelegate {
    func deleteActionDidTapped(_ selectedTask: TaskModel) {
        coreDataManager?.delete(selectedTask)
        self.taskList.removeAll{ $0.id == selectedTask.id }
      }
    
}
