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
    }
}
