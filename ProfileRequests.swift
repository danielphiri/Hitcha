//
//  ProfileRequests.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/29/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

func store(data: Data, toPath path: String) {
    let storageRef = FIRStorage.storage().reference()
    
    // YOUR CODE HERE
    
    storageRef.child(path).put(data, metadata: nil, completion: { (metadata, error) in
        if let error = error {
            print("Error uploading: \(error)")
        }
    })
    
}
var userName = ""
var thisBio = ""

var profilePic: UIImage?
//FIRAuth.auth.currentuser

func addProfilePic(pic: UIImage) {
    let dbRef = FIRDatabase.database().reference()
    let data = UIImageJPEGRepresentation(pic, 1.0)!
    let path = "\(firStorageImagesPath)/\(UUID().uuidString)"
    let properties: [String: String] = [firProfilePic: path]
    
//    dbRef.child(firProfiles).child((FIRAuth.auth()?.currentUser?.uid)!).childByAutoId().setValue(properties)

    if uid != "" {
        dbRef.child(firProfiles).child(uid).child(firProfilePic).setValue(path)
        store(data: data, toPath: path)
    } else {
        dbRef.child(firProfiles).child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(properties)
        store(data: data, toPath: path)
    }
    
}


func addBio(bioG: String) {
    
    let dbRef = FIRDatabase.database().reference()
   // let data = UIImageJPEGRepresentation(pic, 1.0)!
    //let path = "\(firStorageImagesPath)/\(UUID().uuidString)"
    let properties: [String: String] = [firBio: bioG]
    thisBio = bioG
    dbRef.child(firProfiles).child(uid).updateChildValues(properties)
    //store(data: data, toPath: path)
}

func updateProfileInfo(email: String, username: String, lastName: String) {
    let dbRef = FIRDatabase.database().reference()
    // let data = UIImageJPEGRepresentation(pic, 1.0)!
    //let path = "\(firStorageImagesPath)/\(UUID().uuidString)"
    print(email + "ok" + username + "ok" + lastName)
    let properties: [String: String] = [firUserEmail: email, firUsername: username, firLastName: lastName]
    print(properties)
    //dbRef.child(firProfiles).childByAutoId().setValue(properties)
    if uid != "" {
         dbRef.child(firProfiles).child(uid).setValue(properties)
    } else {
        dbRef.child(firProfiles).child((FIRAuth.auth()?.currentUser?.uid)!).setValue(properties)
    }
    
    
}

func updateMoves(originLat: String, originLong: String, destinLat: String, destinLong: String, mode: String, url: String) {
    let dbRef = FIRDatabase.database().reference()
    //let data = UIImageJPEGRepresentation(postImage, 1.0)!
    //let path = "\(firStorageImagesPath)/\(UUID().uuidString)"
    // YOUR CODE HERE
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    let properties: [String: String] = [firOriginLatitude: originLat, firOriginalLongitude: originLong, firDestinationLatitude: destinLat, firDestinationLongitude: destinLong, firMode: mode, firJourneyUrl: url]
    print(url)
    print(properties)
    dbRef.child(firOnTheMove).child(uid).updateChildValues(properties)
    //store(data: data, toPath: path)
}

func updateWith(with: String) {
    let dbRef = FIRDatabase.database().reference()
    //let data = UIImageJPEGRepresentation(postImage, 1.0)!
    //let path = "\(firStorageImagesPath)/\(UUID().uuidString)"
    // YOUR CODE HERE
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    let properties: [String: String] = [firWithUser: with]
    dbRef.child(firOnTheMove).child(uid).updateChildValues(properties)
    
}




func getPosts(userId: String) {
    let dbRef = FIRDatabase.database().reference()
    var postArray: [String] = []

    // YOUR CODE HERE
    dbRef.child(firProfiles).observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? [String: AnyObject]
        var userReadPosts = [String: String]()
        dbRef.child(firOnTheMove).queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (data) in
                if let userReadPosts = (data.value as? [String: String]?)! {

                }
        }) { (error) in
           // completion(nil)
        }
        for key in (value?.keys)! {
            var keyInRead = false
            //            if userReadPosts.keys.contains(key) {
            //                var keyInRead = true
            //            }
            //            var imgPath = value?[firImagePathNode] as! [String]
            //            var threadVal = value?[firThreadNode] as! [String]
            //            var date = value?[firDateNode] as! [String]
            if let user1 = value?[key] as! [String: String]? {

                //let post = Post(id: key, username: user1["username"]!, postImagePath: user1["imagePath"]!, thread: user1["thread"]!, dateString: user1["date"]!, read: keyInRead)
                postArray.append("")
            }
        }

       // completion(postArray)
    }) { (error) in
        //completion(nil)
    }

}


func getBio(bio: UserMenuViewController) {
    let dbRef = FIRDatabase.database().reference()
    //var postArray: [String] = []
    
    // YOUR CODE HERE
    dbRef.child(firProfiles).observe(FIRDataEventType.value, with: { (snapshot) in
        let value = snapshot.value as? [String: AnyObject]
        print(value)
        print(value?.keys)
        for key in (value?.keys)! {
            //var keyInRead = false
            if let user1 = value?[key] as! [String: String]? {
                //for userKey in user1.keys {
                //let val = value?[key] as! [String: String]
               // if val == firBio  {
                    // print(userKey)
                for valu in user1.keys {
                    if valu == firBio {
                        thisBio = user1[valu]!
                        bio.userBio.text = thisBio
                    } else if valu == firProfiles {
                        thisName = user1[valu]!
                    }
                }
                
            }
        }
        
        // completion(postArray)
    }) { (error) in
        //completion(nil)
    }

}


func getThis() {
    let dbRef = FIRDatabase.database().reference()
    //var postArray: [String] = []
    
    // YOUR CODE HERE
    dbRef.child(firProfiles).observe(FIRDataEventType.value, with: { (snapshot) in
        let value = snapshot.value as? [String: AnyObject]
        print(value)
        print(value?.keys)
        for key in (value?.keys)! {
            //var keyInRead = false
            if let user1 = value?[key] as! [String: String]? {
                //for userKey in user1.keys {
                //let val = value?[key] as! [String: String]
                // if val == firBio  {
                // print(userKey)
                for valu in user1.keys {
                    if valu == firBio {
                        thisBio = user1[valu]!
                      //  bio.userBio.text = thisBio
                    } else if valu == firUsername {
                        thisName = user1[valu]!
                    }
                }
                
            }
        }
        
        // completion(postArray)
    }) { (error) in
        //completion(nil)
    }
    
}













func getProfileImage(userId: String, clas: UserMenuViewController) {
    let dbRef = FIRDatabase.database().reference()
    //var postArray: [String] = []
    
    // YOUR CODE HERE
    dbRef.child(firProfiles).observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? [String: AnyObject]
        // var userReadPosts = [String: String]()
        /* Check this one out. */
        //        dbRef.child(firProfiles).queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (data) in
        //            if let userReadPosts = (data.value as? [String: String]?)! {
        //
        //                postArray.append(userReadPosts[firProfilePic]!)
        //                print(postArray)
        //                print(userReadPosts)
        //                print(userReadPosts[firProfilePic]!)
        //                for strin in postArray {
        //                    getDataFromPath(path: strin, completion: { (imgData) in
        //                        if imgData != nil {
        //                        let img = UIImage(data: imgData!)
        //                        //self.loadedImagesById[post.postId] = img
        //                            profilePic = img!
        //                        }
        //
        //                        })
        //                }
        //                //return getDataFromPath(path: userReadPosts[firProfilePic]!, completion: data.value as! (Data?) -> Void)
        //            }
        //        }) { (error) in
        //            // completion(nil)
        //        }
        print(value)
        print(value?.keys)
        for key in (value?.keys)! {
            //var keyInRead = false
            if let user1 = value?[key] as! [String: String]? {
                //for userKey in user1.keys {
                    if key == userId {
                       // print(userKey)
                        print(user1)
                        print(user1.keys)
                       // print(user1[userKey]!)
//                        getDataFromPath(path: user1[userKey]!, completion: { (imgData) in
                        //if profilePic != nil {
                            getDataFromPath(path: user1[firProfilePic]!, completion: { (imgData) in
                                if imgData != nil {
                                //print(userKey)
                                //print(user1[userKey]!)
                                                                let img = UIImage(data: imgData!)
                                //self.loadedImagesById[post.postId] = img
                                    profilePic = img!
                                  //  UserMenuViewController.updateImageAndPic()
                                    clas.userImagView.image = profilePic
                                }
                            
                            })
                       // }
                    }
                //}
            }
        }
        
        // completion(postArray)
    }) { (error) in
        //completion(nil)
    }
}


func updateFireBase() {
    
}


var thisFrom = ""
var thisTo = ""
var thisName = ""

func matchUsers() {
    let dbRef = FIRDatabase.database().reference()
    //var postArray: [String] = []
    
    // YOUR CODE HERE
    dbRef.child(firOnTheMove).observe(FIRDataEventType.value, with: { (snapshot) in
        let value = snapshot.value as? [String: AnyObject]
        print(value)
        print(value?.keys)
        for key in (value?.keys)! {
            //var keyInRead = false
            if let user1 = value?[key] as! [String: String]? {
                //for userKey in user1.keys {
                //let val = value?[key] as! [String: String]
                // if val == firBio  {
                // print(userKey)
                for valu in user1.keys {
                    if valu == firOriginLatitude {
                        thisFrom = user1[valu]!
                        
                        //bio.userBio.text = thisBio
                    } else if valu == firDestinationLatitude {
                        thisTo = user1[valu]!
                        
                        //bio.userBio.text = thisBio
                    } else if valu == firUsername {
                        thisName = user1[valu]!
                    }
                }
                
            }
        }
        
        // completion(postArray)
    }) { (error) in
        //completion(nil)
    }

}



/* Final, don't touch. For getting the user's username for display on app. */
func getNames(userId: String, clas: UserMenuViewController) {
    let dbRef = FIRDatabase.database().reference()
    var firstName = ""
    print(FIRAuth.auth()?.currentUser)
    var kind: String?
    kind = (FIRAuth.auth()?.currentUser?.displayName)
    firstName = flaten(st: kind)
    //var name = ""
    var nameCount = 0
    var usCount = 0
    var userName = ""
    //let rName = flaten(st: FIRAuth.auth()?.currentUser?.displayName)
    userName = userName + firstName + " "
    dbRef.child(firProfiles).observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? [String: AnyObject]
        for key in (value?.keys)! {
        //let key =
            if let user1 = value?[key] as! [String: String]? {
                for userKey in user1.keys {
                    if userKey == firLastName && nameCount == 0 {
                        nameCount += 1
                        let realName = flaten(st: user1[userKey]!)
                        userName = userName + realName + ". " + "\n"
                    }
                }
            }
        }
        
        for key in (value?.keys)! {
            if let user1 = value?[key] as! [String: String]? {
                for userKey in user1.keys {
                    if userKey == firUsername && usCount == 0 {
                        usCount += 1
                        let usdName = user1[userKey]
                        userName = userName + "@" + usdName!
                        clas.profileName.text = userName
                    }
                }
            }
        }
        // completion(postArray)
    }) { (error) in
        //completion(nil)
        print(error.localizedDescription)
    }
    //return name
}

func flaten(st: String?) -> String {
    var s = ""
    if let r = st {
        for k in r.characters {
            if k != "." && k != " " {
                s = s + k.description
            }
        }
    }
    return s
}

func getDataFromPath(path: String, completion: @escaping (Data?) -> Void) {
    let storageRef = FIRStorage.storage().reference()
    //let storageRef = FIRStorage.storage().reference(forURL: dataUrl)
    storageRef.child(path).data(withMaxSize: 60 * 1024 * 1024) { (data, error) in
        if let error = error {
            
            print(path)
            print(error)
            let t = 0
        }
        if let data = data {
            completion(data)
        
        } else {
            completion(nil)
        }
}
}
