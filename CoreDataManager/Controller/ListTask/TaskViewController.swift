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
       // let predicate = PredicateFormatter(key: "key", value: "value", formatType: .greaterThanEqual)
        //let batch = BatchOperationManager(entityName: "entity", predicateFormatter: predicate)
         coreDataManager = CoreDataManager()
        fetchTask()
    }
    
    func fetchTask() {
        coreDataManager!.fetchListAsync(TaskModel.self) { (result) in
            if let taskList = result as? [TaskModel] {
                self.taskList = taskList
            }
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
        /*
        let addedTask :TaskModel = TaskModel()
        do {
        try coreDataManager?.saveContext()
        }
        catch {
            print("error during saving")
        }
 */
    }
}
