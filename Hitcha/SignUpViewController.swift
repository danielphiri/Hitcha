//
//  SignUpViewController.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/10/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextInput: UITextField!
    
    @IBOutlet weak var lastNameInput: UITextField!
    
    @IBOutlet weak var emailInput: UITextField!
    
    @IBOutlet weak var userNameInput: UITextField!
    
    @IBOutlet weak var passwordFirstInput: UITextField!
    
    @IBOutlet weak var verifyPasswordInput: UITextField!
    
    @IBAction func signUpButton(_ sender: UIButton) {
        guard let email = emailInput.text else { return }
        guard let password = passwordFirstInput.text else { return }
        guard let name = firstNameTextInput.text else { return }
        if email == "" || password == "" || name == "" || firstNameTextInput.text == ""
        || lastNameInput.text == "" || userNameInput.text == ""
        || passwordFirstInput.text == "" || verifyPasswordInput.text == "" {
            let alertController = UIAlertController(title: "Form Error.", message: "Please fill in form completely.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                if (self.passwordFirstInput.text != self.verifyPasswordInput.text) {
                    let alertController = UIAlertController(title: "Verification Error.", message: "The two passwords do not match.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                } else if error == nil {
                    let changeReq = user!.profileChangeRequest()
                    changeReq.displayName = self.firstNameTextInput.text! + "."
                    changeReq.commitChanges(completion:
                        { (err) in
                            if let err = err {
                                print(err)
                            } else {
                            }
                    })
                    uid = (FIRAuth.auth()?.currentUser?.uid)!
                    updateProfileInfo(email: email, username: self.userNameInput.text!, lastName: self.lastNameInput.text!)
                    let alertController = UIAlertController(title: "Congratulations!", message: "You have successfully signed up", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler:
                        {
                            [unowned self] (action) -> Void in
                            self.performSegue(withIdentifier: "signUpToMain", sender: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Sign Up Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
