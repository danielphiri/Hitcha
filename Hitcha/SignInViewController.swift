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
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Log In Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: emailText, password: passwordText) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginToMain")
                    //                    self.present(vc!, animated: true, completion: nil)
                    self.performSegue(withIdentifier: "signInToMain", sender: nil)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Log In Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    //self.performSegue(withIdentifier: "loginToMain", sender: nil)
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
        // Do any additional setup after loading the view, typically from a nib.
        CompanyImage.image = #imageLiteral(resourceName: "Hitcha (2)")
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

