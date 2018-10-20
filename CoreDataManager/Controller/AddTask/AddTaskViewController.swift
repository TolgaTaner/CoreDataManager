//
//  AddTaskViewController.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 20.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

protocol AddTaskViewControllerDelegate {
    func pop(_ taskName:String)
}

class AddTaskViewController: UIViewController {
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    var actionDelegate:AddTaskViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
        taskNameTextField.delegate = self
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            self?.actionDelegate?.pop(self?.taskNameTextField.text ?? "" )
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension AddTaskViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
