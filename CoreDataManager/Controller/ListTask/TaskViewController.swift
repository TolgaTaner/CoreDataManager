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
        tasksTableView.actionDelegate = self 
     fetchTask()
    }
    
    func fetchTask() {
        CoreDataManager.shared.fetchListAsync(TaskModel.self) { [weak self]  (result) in
            if let taskList = result as? [TaskModel] {
                self?.taskList = taskList
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
    
    func deleteAllTask() {
        do {
            try CoreDataManager.shared.deleteWithBatch(TaskModel.self)
        }
        catch let err {
            print(err)
        }
    }
 */
    
    
}

extension TaskViewController : TaskNavigationControllerDelegate {
    func deleteAllButtonTapped() {
        deleteAllTask()
        self.taskList.removeAll()
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
        let addedTask :TaskModel = TaskModel(name: taskName, context: CoreDataManager.shared.privateMoc!)
      do {
        try? CoreDataManager.shared.saveContext(type: .background)
        self.taskList.append(addedTask)
        }
    }
}

extension TaskViewController:TasksTableViewDelegate {
    func deleteActionDidTapped(_ selectedTask: TaskModel) {
        CoreDataManager.shared.delete(selectedTask)
        self.taskList.removeAll{ $0.id == selectedTask.id }
      }
    
}
