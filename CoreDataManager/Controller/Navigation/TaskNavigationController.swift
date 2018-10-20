//
//  TaskNavigationController.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 20.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

protocol TaskNavigationControllerDelegate {
    func addButtonTapped()
}

class TaskNavigationController: UINavigationController {

    
    var actionDelegate:TaskNavigationControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let theVisibleViewController = self.visibleViewController   {
            if theVisibleViewController is TaskViewController {
                self.setAddButton(theVisibleViewController)
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
    
    @objc func addButtonTapped() {
        actionDelegate?.addButtonTapped()
    }
    


}
