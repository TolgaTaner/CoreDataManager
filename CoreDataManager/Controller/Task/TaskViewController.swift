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
        //let manager = CoreDataManager(batchOperation: batch)
    }

}

extension TaskViewController : TaskNavigationControllerDelegate {
    func addButtonTapped() {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTaskViewController") as? AddTaskViewController {
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
    }
    
}
