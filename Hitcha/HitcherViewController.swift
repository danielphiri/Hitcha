//
//  HitcherViewController.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/18/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import Firebase
import FirebaseAuth


class HitcherViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    var destination: CLLocation?
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    @IBOutlet weak var homeButton: UIButton!
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        mapView.clear()
        if selectedPlace != nil {
            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        listLikelyPlaces()
    }

    @IBOutlet weak var address_line_1: UITextField!
    @IBOutlet weak var address_line_2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var postal_code_field: UITextField!
    @IBOutlet weak var country_field: UITextField!
    @IBOutlet weak var button: UIButton!
    var street_number: String = ""
    var route: String = ""
    var neighborhood: String = ""
    var locality: String = ""
    var administrative_area_level_1: String = ""
    var country: String = ""
    var postal_code: String = ""
    var postal_code_suffix: String = ""
    var hitchOrDrive = ""
    var marker: GMSMarker?
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        // Set a filter to return only addresses.
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .address
        autocompleteController.autocompleteFilter = addressFilter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var movingButton: UIButton!
    
    @IBAction func movingButtonPressed(_ sender: UIButton) {
        
        getDirections(start: locationManager, end: selectedPlace!)
        matchUsers(userId: (FIRAuth.auth()?.currentUser?.uid)!)
        if hitchOrDrive == "drive" {
        if thisFrom != "" || thisTo != "" {
            if thisName != "" {
            let alertController = UIAlertController(title: "You're not alone! ", message: "@\(thisName)" + " is driving from \(thisFrom) to \(thisTo). Do you want to join?", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Yes", style: .default, handler:  {
                [unowned self] (action) -> Void in
                self.cance()
            })
                let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "You're not alone! ", message: "Someone" + " is driving from \(thisFrom) to \(thisTo). Do you want to join?", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Yes", style: .default, handler:  {
                    [unowned self] (action) -> Void in
                    self.cance()
                })
                let cancelAction = UIAlertAction(title: "No", style: .cancel, handler:nil)
                alertController.addAction(defaultAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
    
    func cance() {
        let alertController = UIAlertController(title: "Your Request Has Been Sent", message: "We will notify you shortly when the user responds.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getDirections(start: CLLocationManager, end: GMSPlace) {
        var directions = String()
        CLGeocoder().reverseGeocodeLocation(start.location!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                let alert = UIAlertController(title: "Reverse geocoder failed with error:", message: (error?.localizedDescription)!, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0] as! CLPlacemark
                directions = self.directionsURL + "origin=" + self.flattenString(string: pm.name!)
                    + "&destination=" + self.flattenString(string: end.formattedAddress!)
                self.directionsURL = directions
                let fromLat = self.locationManager.location?.coordinate.latitude.debugDescription
                let fromLong = self.locationManager.location?.coordinate.longitude.debugDescription
                let destLat = self.destination?.coordinate.latitude.debugDescription
                let destLong = self.destination?.coordinate.longitude.debugDescription
                var mod = ""
                if self.hitchOrDrive == "drive" {
                    mod = firHitching
                } else {
                    mod = firDriving
                }
                updateMoves(originLat: pm.name!, originLong: fromLong!, destinLat: end.formattedAddress!, destinLong: destLong!, mode: mod, url: self.directionsURL)
                self.directionsURL = "https://maps.googleapis.com/maps/api/directions/json?"
                self.networkRequest(withUrl: directions, completionHandler: {_,_ in (placemarks)})
            }
            else {
                let alert = UIAlertController(title: "Problem with the data received from geocoder", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:nil))
                self.present(alert, animated: true, completion: nil)
            }
        })

    }
    
    func flattenString(string: String) -> String {
        var str = ""
        let chars = string.characters
        for char in chars {
            if char != " " {
                str = str + char.description
            }
        }
        return str
    }

    
    func networkRequest(withUrl url: String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        let headers: HTTPHeaders = [
            "Authorization": GoogleMapsApi,//"Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        request(url, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                let color = data as! [String: Any]
                let array = (color["routes"]! as! NSArray).mutableCopy() as! NSMutableArray
                if array.count == 0 {
                    if self.hitchOrDrive == "hitch" {
                        let alertController = UIAlertController(title: "Address Error.", message: "There is no driving route to your destination. Please make another selection.", preferredStyle: .alert)
                    
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else if self.hitchOrDrive == "drive" {
                        let alertController = UIAlertController(title: "Address Error.", message: "There is no hitching route to your destination. Please make another selection.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    break
                }
                let dict = array[0] as! [String: Any]
                let firstC = dict["bounds"] as! [String: Any]
                let firstCo = firstC["northeast"] as! [String: Any]
                let firstCoLat = firstCo["lat"] as! Double
                let firstCoLng = firstCo["lng"] as! Double
                self.path.add(CLLocationCoordinate2D(latitude: firstCoLat, longitude: firstCoLng))
                let secCo = firstC["southwest"] as! [String: Any]
                let secCoLat = secCo["lat"] as! Double
                let secCoLng = secCo["lng"] as! Double
                self.path.add(CLLocationCoordinate2D(latitude: secCoLat, longitude: secCoLng))
                let dict2 = (dict["legs"] as! NSArray).mutableCopy() as! NSMutableArray
                let aye = dict2[0] as! [String: Any]
                let stake = (aye["steps"] as! NSArray).mutableCopy() as! NSMutableArray
                self.makeRoute(route: stake)
                completionHandler(data as? NSDictionary, nil)
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }

    }
    
    let path = GMSMutablePath()
    func makeRoute(route: NSMutableArray) {
        
        for item in route {
            let route = item as! [String: Any]
            let startL = route["polyline"]
            let changeEm = startL as! [String: Any]
            let startLat = changeEm[ "points"]
            let startLatitude = startLat as! String
            let newPath = GMSPath(fromEncodedPath: startLatitude)
            let polyline = GMSPolyline(path: newPath)
            if self.hitchOrDrive == "hitch" {
                polyline.strokeColor = UIColor.red
            }
            polyline.strokeWidth = 5.0
            polyline.map = mapView
        }
    }
    
    
    func checkPoints(userUrl: String, otherUser: String) {
        let headers: HTTPHeaders = [
            "Authorization": GoogleMapsApi,//"Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        request(otherUser, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                let color = data as! [String: Any]
                let array = (color["routes"]! as! NSArray).mutableCopy() as! NSMutableArray
                if array.count == 0 {
                    if self.hitchOrDrive == "hitch" {
                        let alertController = UIAlertController(title: "Address Error.", message: "There is no driving route to your destination. Please make another selection.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else if self.hitchOrDrive == "drive" {
                        let alertController = UIAlertController(title: "Address Error.", message: "There is no hitching route to your destination. Please make another selection.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    break
                }
                let dict = array[0] as! [String: Any]
                let firstC = dict["bounds"] as! [String: Any]
                let firstCo = firstC["northeast"] as! [String: Any]
                let firstCoLat = firstCo["lat"] as! Double
                let firstCoLng = firstCo["lng"] as! Double
                self.path.add(CLLocationCoordinate2D(latitude: firstCoLat, longitude: firstCoLng))
                let secCo = firstC["southwest"] as! [String: Any]
                let secCoLat = secCo["lat"] as! Double
                let secCoLng = secCo["lng"] as! Double
                self.path.add(CLLocationCoordinate2D(latitude: secCoLat, longitude: secCoLng))
                let dict2 = (dict["legs"] as! NSArray).mutableCopy() as! NSMutableArray
                let aye = dict2[0] as! [String: Any]
                let stake = (aye["steps"] as! NSArray).mutableCopy() as! NSMutableArray
                self.makeRoute(route: stake)
            case .failure(let error):
                let alert = UIAlertController(title: "There seems to have been a problem:", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    var directionsURL = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self as CLLocationManagerDelegate
        placesClient = GMSPlacesClient.shared()
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        //view.addSubview(mapView)
        view.addSubview(mapView)
        view.addSubview(homeButton)
        view.addSubview(button)
        mapView.isHidden = true
        
        // Creates a marker in the center of the map.
        listLikelyPlaces()
        matchUsers(userId: (FIRAuth.auth()?.currentUser?.uid)!)
        getThis(userId: (FIRAuth.auth()?.currentUser?.uid)!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if self.restorationIdentifier == "hitcher" {
            self.hitchOrDrive = "hitch"
        } else if self.restorationIdentifier == "driver" {
            self.hitchOrDrive = "drive"
        }
    }
    
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                let alert = UIAlertController(title: "Current Place error:", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }
    
    // Prepare the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSelect" {
            if let nextViewController = segue.destination as? PlacesViewController {
                nextViewController.likelyPlaces = likelyPlaces
            } else if let nextViewController = segue.destination as? PlacesViewController {
                nextViewController.likelyPlaces = likelyPlaces
            }

        } else if segue.identifier == "forwardToPic" {
            if let nextViewController = segue.destination as? DriverViewController {
                nextViewController.image.image = profilePic
            }
        }
    }
}

// Delegates to handle events for the location manager.
extension HitcherViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        destination = location//.coordinate
        //selectedPlace?.coordinate = lo
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
            mapView.snapshotView(afterScreenUpdates: true)
        } else {
            mapView.animate(to: camera)
        }
        listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

    // Populate the address form fields.
    func fillAddressForm(place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                              longitude: place.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the map to the view, hide it until we've got a location update.
        //view.addSubview(mapView)
        view.addSubview(mapView)
        view.addSubview(homeButton)
        view.addSubview(button)
        view.addSubview(movingButton)
        marker = GMSMarker()
        marker?.position = place.coordinate
        marker?.title = place.description
        marker?.map = mapView
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
    }
}

extension HitcherViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        selectedPlace = place
        
        
        // Get the address components.
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                //currentLocation? = locationManager.
                switch field.type {
                case kGMSPlaceTypeStreetNumber:
                    street_number = field.name
                case kGMSPlaceTypeRoute:
                    route = field.name
                case kGMSPlaceTypeNeighborhood:
                    neighborhood = field.name
                case kGMSPlaceTypeLocality:
                    locality = field.name
                case kGMSPlaceTypeAdministrativeAreaLevel1:
                    administrative_area_level_1 = field.name
                case kGMSPlaceTypeCountry:
                    country = field.name
                case kGMSPlaceTypePostalCode:
                    postal_code = field.name
                case kGMSPlaceTypePostalCodeSuffix:
                    postal_code_suffix = field.name
                // Print the items we aren't using.
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        }
        
        // Call custom function to populate the address form.
        fillAddressForm(place: place)
        
        // Close the autocomplete widget.
        self.dismiss(animated: true, completion: nil)
    }


    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Show the network activity indicator.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    // Hide the network activity indicator.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }



}


