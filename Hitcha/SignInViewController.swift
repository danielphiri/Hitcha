//
//  ViewController.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/10/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import UIKit
//import GoogleMaps
import Firebase
import FirebaseAuth


class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var CompanyImage: UIImageView!
    
    @IBOutlet weak var userNameInput: UITextField!
    
    @IBOutlet weak var passwordInput: UITextField!
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    @IBAction func logInPushed(_ sender: UIButton) {
        guard let emailText = userNameInput.text else { return }
        guard let passwordText = passwordInput.text else { return }
        
        if self.userNameInput.text == "" || self.passwordInput.text == "" {
            let alertController = UIAlertController(title: "Log In Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: emailText, password: passwordText) { (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "signInToMain", sender: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "Log In Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    deinit {
        if let handle = handle {
            FIRAuth.auth()?.removeStateDidChangeListener(handle)
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        CompanyImage.image = UIImage(named: "Hitcha-2")
        userNameInput.delegate = self
        passwordInput.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Checks if user is already signed in and skips login
        if FIRAuth.auth()?.currentUser != nil {
            self.performSegue(withIdentifier: "signInToMain", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}

