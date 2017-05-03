//
//  UserMenuViewController.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/16/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//
import Firebase
import FirebaseAuth
import UIKit

class UserMenuViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    //@IBOutlet weak var userBio: UITextView!
    
    @IBAction func logout(_ sender: UIButton) {
        try! FIRAuth.auth()!.signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "home") as! SignInViewController
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var profileName: UILabel!
    
    
    @IBOutlet weak var userImagView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    var imageViewed = DriverViewController()
    
    
    
   // @IBOutlet weak var menuTableView: UITableView!
    
    
    //@IBOutlet weak var menuTableView: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let singleTap =  UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(handleTap:)))
        
        let itTapped =  UITapGestureRecognizer.init(target: self, action: #selector(self.handleIt(handleTap:)))
        
        singleTap.delegate = self
        itTapped.delegate = self
        userImagView.isUserInteractionEnabled = true
        userBio.isUserInteractionEnabled = true
        //alloc] initWithTarget:self action:@selector(singleTapping:)];
        //singleTap.numberOfTapsRequired = 1
        userImagView.addGestureRecognizer(singleTap)
        userBio.addGestureRecognizer(itTapped)
        self.view.addSubview(userImagView)
        self.view.addSubview(userBio)
        uid = (FIRAuth.auth()?.currentUser?.uid)!
        //self.view.addSubview(userImagView)
        self.view.addSubview(profileName)
        getProfileImage(userId: uid, clas: self)
        if (profilePic != nil) {
            userImagView.image = profilePic
        }
        getNames(userId: uid, clas: self)
        profileName.text = userName
        getBio(bio: self)
        if thisBio != "" {
            userBio.text = thisBio
        }
    }
    
//    static func updateImageAndPic() {
//        up()
//    }
    
    func up() {
        if (profilePic != nil) {
            userImagView.image = profilePic
        }
        profileName.text = userName
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let singleTap =  UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(handleTap:)))
//        
//        
//        
//        singleTap.delegate = self
//        userImagView.isUserInteractionEnabled = true
//        //alloc] initWithTarget:self action:@selector(singleTapping:)];
//        //singleTap.numberOfTapsRequired = 1
//        userImagView.addGestureRecognizer(singleTap)
//        self.view.addSubview(userImagView)
//        uid = (FIRAuth.auth()?.currentUser?.uid)!
//        self.view.addSubview(userImagView)
//        self.view.addSubview(profileName)
//        getProfileImage(userId: uid)
//        if (profilePic != nil) {
//            userImagView.image = profilePic
//        }
//        getNames(userId: uid)
//        profileName.text = userName
        print("halleluya")
//        
    }
    
    
    
    
    func handleIt(handleTap: UITapGestureRecognizer) {
        
//        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
//        let chooseAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {
//            [unowned self] (action) -> Void in
//            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
//                print("Button capture")
//                
//                self.imagePicker.delegate = self
//                self.imagePicker.sourceType = .savedPhotosAlbum;
//                self.imagePicker.allowsEditing = false
//                
//                self.present(self.imagePicker, animated: true, completion: nil)
//            }
//        })
//        //        let viewImage = UIAlertAction(title: "View Profile Picture", style: .default, handler: {
//        //            [unowned self] (action) -> Void in
//        ////            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
//        //                //print("Button capture")
//        //
//        ////                self.imagePicker.delegate = self
//        ////                self.imagePicker.sourceType = .savedPhotosAlbum;
//        ////                self.imagePicker.allowsEditing = false
//        //                self.performSegue(withIdentifier: "forwardToPic", sender: nil)
//        //                //self.present(self.imageViewed, animated: true, completion: nil)
//        //           // }
//        //        })
//        
//        alertController.addAction(UIAlertAction(title: "View Profile Picture", style: .default, handler:
//            {
//                [unowned self] (action) -> Void in
//                self.performSegue(withIdentifier: "forwardToPic", sender: nil)
//        }))
//        
//        let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertController.addAction(chooseAction)
//        alertController.addAction(defaultAction)
        //alertController.addAction(viewImage)
        self.performSegue(withIdentifier: "typeBioSegue", sender: nil)
        //self.present(alertController, animated: true, completion: nil)
    }
    
    
    

    
//    func singleTapping(recognizer: UIGestureRecognizer) {
    func handleTap(handleTap: UITapGestureRecognizer) {
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let chooseAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {
            [unowned self] (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
    })
//        let viewImage = UIAlertAction(title: "View Profile Picture", style: .default, handler: {
//            [unowned self] (action) -> Void in
////            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
//                //print("Button capture")
//                
////                self.imagePicker.delegate = self
////                self.imagePicker.sourceType = .savedPhotosAlbum;
////                self.imagePicker.allowsEditing = false
//                self.performSegue(withIdentifier: "forwardToPic", sender: nil)
//                //self.present(self.imageViewed, animated: true, completion: nil)
//           // }
//        })
        
        alertController.addAction(UIAlertAction(title: "View Profile Picture", style: .default, handler:
            {
                [unowned self] (action) -> Void in
                self.performSegue(withIdentifier: "forwardToPic", sender: nil)
        }))
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(chooseAction)
        alertController.addAction(defaultAction)
        //alertController.addAction(viewImage)
        
        self.present(alertController, animated: true, completion: nil)
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
    
    // MARK: Tableview delegate and datasource methods
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! MenuContentTableViewCell
//        cell.menuPrototype.text = menuItems[indexPath.row]
////        cell.menuPrototype.textColor = UIColor.white
////        cell.backgroundColor = UIColor.black
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return menuItems.count
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//       // chosenThreadLabel.text = threadNames[indexPath.row]
//        if indexPath.row == 0 {
//            performSegue(withIdentifier: "profileInfoSegue", sender: self)
//        } else {
//            performSegue(withIdentifier: "otherUserInfoSegue", sender: self)
//        }
//    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print("Eureka!!!")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.userImagView.contentMode = .scaleAspectFit
            self.userImagView.contentMode = .scaleToFill
            self.userImagView.image = pickedImage
            
//            let changeReq = FIRAuth.auth()?.currentUser?.profileChangeRequest()
//            changeReq?.photoURL.ph = pickedImage
//            changeReq.commitChanges(completion:
//                { (err) in
//                    if let err = err {
//                        print(err)
//                    } else {
//                        
//                    }
//                    
//            })
            addProfilePic(pic: pickedImage)
            
            
            
            self.dismiss(animated: true, completion: { () -> Void in
                
                        })
        }
        
    }
//    override func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
//        self.dismiss(animated: true, completion: { () -> Void in
//            
//        })
//        self.userImagView.contentMode = .scaleAspectFit
//        self.userImagView.image = image
//        
//    }
    
//    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
////        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
////            ç
////            self.imageView.image = pickedImage
////        }
////        
////        ç
////        
//    }
    

}
