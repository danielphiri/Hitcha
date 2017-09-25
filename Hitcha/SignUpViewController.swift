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
   // @IBOutlet weak var firstNameInput: UILabel!
    
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
            //FIRAuth.auth().
            FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                
                if error == nil {
                    //NSUserName() = nam
                    //CurrentUser.username = name
                    // user?.displayName = name
                    //FIRAuth.auth()?.currentUser?.profileChangeRequest().displayName = name + self.lastNameInput.text!
                    //var user = FIRuser(userNameInput.text)
                    //user.setValue(user)
                    let changeReq = user!.profileChangeRequest()
                    changeReq.displayName = self.firstNameTextInput.text! + "."
                    changeReq.commitChanges(completion:
                        { (err) in
                            if let err = err {
                                print(err)
                            } else {
                                
                            }
                            
                    })

                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    uid = (FIRAuth.auth()?.currentUser?.uid)!
                    updateProfileInfo(email: email, username: self.userNameInput.text!, lastName: self.lastNameInput.text!)
                    let alertController = UIAlertController(title: "Congratulations!", message: "You have successfully signed up", preferredStyle: .alert)
                    
                    //let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    /*alertController.addAction(defaultAction)*/
                    
                    
                    //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "signupToMain")
                    //                    self.present(vc!, animated: true, completion: nil)
                    alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler:
                        {
                            [unowned self] (action) -> Void in
                            self.performSegue(withIdentifier: "signUpToMain", sender: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    
                } else if (self.passwordFirstInput.text != self.verifyPasswordInput.text) {
                    let alertController = UIAlertController(title: "Verification Error.", message: "The two passwords do not match.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
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
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
