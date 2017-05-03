//
//  RideSelectionViewController.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/27/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RideSelectionViewController: UIViewController {

    @IBOutlet weak var userGreeting: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FIRAuth.auth()?.currentUser != nil {
            if let name = (FIRAuth.auth()?.currentUser?.displayName) {
                userGreeting.text = "Welcome " + flaten(st: name) + "."
            }
        }

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

}
