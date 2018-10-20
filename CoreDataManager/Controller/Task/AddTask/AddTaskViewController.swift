//
//  AddTaskViewController.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 20.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    

    func configure() {
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
