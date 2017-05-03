//
//  LaunchScreenViewController.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/10/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
//import "SWRevealViewController.h"


class MainViewController: UIViewController {
    
    //@IBOutlet weak var userGreeting: UILabel!
    
    @IBOutlet weak var userGreeting: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
       // userGreeting.text = "Welcome " + (FIRAuth.auth()?.currentUser?.displayName)!

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
//        return UserMenuViewController(nibName: "", bundle: self.nibBundle)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
