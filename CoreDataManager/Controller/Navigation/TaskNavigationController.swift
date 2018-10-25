//
//  TaskNavigationController.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 20.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

protocol TaskNavigationControllerDelegate:class {
    func addButtonTapped()
    func deleteAllButtonTapped()
}

class TaskNavigationController: UINavigationController {

    
    weak var actionDelegate:TaskNavigationControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let theVisibleViewController = self.visibleViewController   {
            if theVisibleViewController is TaskViewController {
                self.setAddButton(theVisibleViewController)
                self.setDeleteButton(theVisibleViewController)
            }
        }
    }
    
    
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   
    
    
    func setAddButton(_ viewController:UIViewController) {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
        viewController.navigationItem.rightBarButtonItems = [addButton]
    }
    func setDeleteButton(_ viewController:UIViewController) {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButtonTapped))
        viewController.navigationItem.leftBarButtonItems = [deleteButton]
    }
    
    @objc func addButtonTapped() {
        actionDelegate?.addButtonTapped()
    }
    
    @objc func deleteButtonTapped() {
      actionDelegate?.deleteAllButtonTapped()
    }
    
}
