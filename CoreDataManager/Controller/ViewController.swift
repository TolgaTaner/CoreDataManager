//
//  ViewController.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 18.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var tasksTableView: TasksTableView!
    var coreDataManager:CoreDataManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       configure()
    }
    
    func configure() {
        
        let predicate = PredicateFormatter(key: "key", value: "value", formatType: .greaterThanEqual)
        let batch = BatchOperationManager(entityName: "entity", predicateFormatter: predicate)
        let manager = CoreDataManager(batchOperation: batch)
        
    }


}

