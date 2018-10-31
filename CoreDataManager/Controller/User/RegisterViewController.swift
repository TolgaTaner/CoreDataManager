//
//  RegisterViewController.swift
//  CoreDataManager
//
//  Created by Tolga Taner on 30.10.2018.
//  Copyright © 2018 Tolga Taner. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var usersurnameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    private var userProfileImage :UIImage? {
        get {
            return userPhotoImageView?.image
        }
        set{
          userPhotoImageView?.image = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.height/2
        userPhotoImageView.layer.masksToBounds = true
        userPhotoImageView.layer.borderWidth = 1
        userPhotoImageView.layer.borderColor = UIColor.black.cgColor
        userPhotoImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        userPhotoImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped() {
        userProfileImage = UIImage(named: "placeholder")
    }

    @IBAction func registerButtonTapped(_ sender: Any) {
        let _ = UserModel(imageData: (userProfileImage?.jpegRepresentationData!)!  , name: usernameTextField.text!, surname: usersurnameTextField.text!, context: CoreDataManager.shared.privateMoc!)
        do {
        try CoreDataManager.shared.saveContext(type: .background)
            print("saved")
        }
        catch  {}
        
    }
    
}




