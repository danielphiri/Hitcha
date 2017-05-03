//
//  BioTextViewController.swift
//  Hitcha
//
//  Created by Daniel Phiri on 5/2/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import UIKit

class BioTextViewController: UIViewController {

    
    @IBOutlet weak var userBioUpdate: UITextView!
    
    
 //   @IBAction func doneTyping(_ sender: Any) {}
    
    
    @IBAction func doneTyping(_ sender: UIButton) {
        addBio(bioG: userBioUpdate.text)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
