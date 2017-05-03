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
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    var destination: CLLocation?
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    @IBOutlet weak var homeButton: UIButton!
    
    
    
    // Update the map once the user has made their selection.
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Clear the map.
        mapView.clear()
        
        // Add a marker to the map.
        if selectedPlace != nil {
            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        
        listLikelyPlaces()
    }

    
    
    
    
    
    
    // Declare UI elements.
    @IBOutlet weak var address_line_1: UITextField!
    @IBOutlet weak var address_line_2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var postal_code_field: UITextField!
    @IBOutlet weak var country_field: UITextField!
    @IBOutlet weak var button: UIButton!
    
    // Declare variables to hold address form values.
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
    
    // Present the Autocomplete view controller when the user taps the search field.
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as! GMSAutocompleteViewControllerDelegate
        
        // Set a filter to return only addresses.
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .address
        autocompleteController.autocompleteFilter = addressFilter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var movingButton: UIButton!
    
    
    
    
    
    
    
    @IBAction func movingButtonPressed(_ sender: UIButton) {
        
        getDirections(start: locationManager, end: selectedPlace!)
        if hitchOrDrive == "drive" {
        if thisFrom != "" || thisTo != "" {
            if thisName != "" {
            let alertController = UIAlertController(title: "You're not alone! ", message: "@\(thisName)" + " is driving from \(thisFrom) to \(thisTo). Do you want to join?", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Yes", style: .default, handler:  {
                [unowned self] (action) -> Void in
                self.cance()
            })
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler:nil)
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
                //var startAddress = CLPlacemark()
        var directions = String()
        
        CLGeocoder().reverseGeocodeLocation(start.location!, completionHandler: {(placemarks, error) -> Void in
            print(start.location!)
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0] as! CLPlacemark
                //startAddress = (placemarks?[0])!
              //  print(pm.locality)
                directions = self.directionsURL + "origin=" + self.flattenString(string: pm.name!)
                    + "&destination=" + self.flattenString(string: end.formattedAddress!)
                //self.makeNetworkCall(directions: directions)
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
                print("Problem with the data received from geocoder")
            }
        })

    }
    
    func flattenString(string: String) -> String {
        var str = ""
       // string.asURL()
        let chars = string.characters
        for char in chars {
            if char != " " {
                str = str + char.description
            }
        }
        
        return str
        
    }

    
    func networkRequest(withUrl url: String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        
        print(url)
        //let headers = ["Content-Type": "application/json", "x-csrf-token":""]
        
        
        
        let headers: HTTPHeaders = [
            "Authorization": GoogleMapsApi,//"Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
       // reque
        request(url, method: .get, headers: headers).validate().responseJSON { response in
          //  print(response.request)  // original URL request
           // print(response.response) // URL response
          //  print(response.data)     // server data
          //  print(response.result)   // result of response serialization
//            if let JSON = response.result.value {
//                print("JSON: \(JSON)")
//                
//            }
            print(url)
            switch response.result {
                
            case .success(let data):
                //print(data)
                //print(response.result)
                let color = data as! [String: Any]
                //print(color)
                //let pols = color["routes"] //as? [String: Any]
                let array = (color["routes"]! as! NSArray).mutableCopy() as! NSMutableArray
                //print(array)
                
                if array.count == 0 {
                    if self.hitchOrDrive == "hitch" {
                        let alertController = UIAlertController(title: "Address Error.", message: "There is no driving route to your destination. Please make another selection.", preferredStyle: .alert)
                    
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                    
                        self.present(alertController, animated: true, completion: nil)
                    } else if self.hitchOrDrive == "drive" {
                        let alertController = UIAlertController(title: "Address Error.", message: "There is no hitching route to your destination. Please make another selection.", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        //defaultAction.
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    break
                }
                
                
                let dict = array[0] as! [String: Any]
                
                let firstC = dict["bounds"] as! [String: Any]
                print(firstC)
                let firstCo = firstC["northeast"] as! [String: Any]
                print(firstCo)
                let firstCoLat = firstCo["lat"] as! Double
                print(firstCoLat)
                let firstCoLng = firstCo["lng"] as! Double
                print(firstCoLng)
                self.path.add(CLLocationCoordinate2D(latitude: firstCoLat, longitude: firstCoLng))
                
//                let secC = dict["bounds"] as! [String: Any]
//                print(secC)
                let secCo = firstC["southwest"] as! [String: Any]
                print(secCo)
                let secCoLat = secCo["lat"] as! Double
                print(secCoLat)
                let secCoLng = secCo["lng"] as! Double
                print(secCoLng)
                self.path.add(CLLocationCoordinate2D(latitude: secCoLat, longitude: secCoLng))
                //print(dict)
                //let dict2 = dict["overview_polyline"] as! [String: Any]
                let dict2 = (dict["legs"] as! NSArray).mutableCopy() as! NSMutableArray
                //self.makeRoute(route: dict2)
                let aye = dict2[0] as! [String: Any]
                //print(aye)
                let stake = (aye["steps"] as! NSArray).mutableCopy() as! NSMutableArray
//                let startLo = aye["start_location"] as! [String: Any]
//                let endLo = aye["end_location"] as! [String: Any]
//                
//                let startLocationLatitude = startLo["lat"] as! Double
//                print(secCoLat)
//                let startLocationLongitude = startLo["lng"] as! Double
//                print(secCoLng)
//                self.path.add(CLLocationCoordinate2D(latitude: startLocationLatitude, longitude: startLocationLongitude))
//                let endLocationLatitude = endLo["lat"] as! Double
//                print(secCoLat)
//                let endLocationLongitude = endLo["lng"] as! Double
//                print(secCoLng)
//                self.path.add(CLLocationCoordinate2D(latitude: endLocationLatitude, longitude: endLocationLongitude))
                
                self.makeRoute(route: stake)
                //print(stake)
               // print(steps)
              //  let points = dict2["points"] as! [GMSMapPoint]
                //GMSPolyline.pathfr
                //self.makeRoute(route: array)
              //  print(points)
              //  let dict = array as! [String: Any]
               // print(dict)
                //let dictPols = pols as! [String: Any]
               // let pols = color["polyline"]// as? [String: NSDictionary]
                //print(dictPols)
               // let realPols = array["overview_polyline"]
                //print(realPols)
                completionHandler(data as? NSDictionary, nil)
            case .failure(let error):
                print(error)
                completionHandler(nil, error as NSError?)
            }
        }
        
        
    }
    
    

    let path = GMSMutablePath()
    func makeRoute(route: NSMutableArray) {
        
        for item in route {
           
            /* Here it the backtrack
            let route = item as! [String: Any]
            let startL = route["start_location"]
            let changeEm = startL as! [String: Any]
            print(changeEm)
            let startLat = changeEm["lat"]
            let startLong = changeEm["lng"]
            //print(startLat)
            let startLatitude = startLat as! Double
            let startLongitude = startLong as! Double
            path.add(CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude))
 */
            let route = item as! [String: Any]
            let startL = route["polyline"]
            let changeEm = startL as! [String: Any]
            print(changeEm)
            let startLat = changeEm[ "points"]
            //let startLong = changeEm["lng"]
            //print(startLat)
            let startLatitude = startLat as! String
            //let startLongitude = startLong as! Double
            let newPath = GMSPath(fromEncodedPath: startLatitude)
            //let path = GMSPath(fromEncodedPath: polyStr)
            let polyline = GMSPolyline(path: newPath)
            if self.hitchOrDrive == "hitch" {
                polyline.strokeColor = UIColor.red
            }
            polyline.strokeWidth = 5.0
            polyline.map = mapView
           /* The backtrack
            let endL = route["start_location"]
            let changeIt = endL as! [String: Any]
            //print(changeIT)
            let endLat = changeIt["lat"]
            let endLong = changeIt["lng"]
            //print(startLat)
            let endLatitude = startLat as! Double
            let endLongitude = startLong as! Double
            path.add(CLLocationCoordinate2D(latitude: endLatitude, longitude: endLongitude))
*/
            //print(startL)
            //let startLongitude = route["end_location"]
        }
        /* Here is the backtrack
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 2
        polyline.strokeColor = UIColor.red
        polyline.geodesic = true
        
        polyline.map = mapView
        
        //print(item)
 */
    }
    
    
    func checkPoints(userUrl: String, otherUser: String) {
        let headers: HTTPHeaders = [
            "Authorization": GoogleMapsApi,//"Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        // reque
        request(otherUser, method: .get, headers: headers).validate().responseJSON { response in
            //  print(response.request)  // original URL request
            // print(response.response) // URL response
            //  print(response.data)     // server data
            //  print(response.result)   // result of response serialization
            //            if let JSON = response.result.value {
            //                print("JSON: \(JSON)")
            //
            //            }
           // print(url)
            switch response.result {
                
            case .success(let data):
                //print(data)
                //print(response.result)
                let color = data as! [String: Any]
                //print(color)
                //let pols = color["routes"] //as? [String: Any]
                let array = (color["routes"]! as! NSArray).mutableCopy() as! NSMutableArray
                //print(array)
                
                if array.count == 0 {
                    if self.hitchOrDrive == "hitch" {
                        let alertController = UIAlertController(title: "Address Error.", message: "There is no driving route to your destination. Please make another selection.", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else if self.hitchOrDrive == "drive" {
                        let alertController = UIAlertController(title: "Address Error.", message: "There is no hitching route to your destination. Please make another selection.", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        //defaultAction.
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    break
                }
                
                
                let dict = array[0] as! [String: Any]
                
                let firstC = dict["bounds"] as! [String: Any]
                print(firstC)
                let firstCo = firstC["northeast"] as! [String: Any]
                print(firstCo)
                let firstCoLat = firstCo["lat"] as! Double
                print(firstCoLat)
                let firstCoLng = firstCo["lng"] as! Double
                print(firstCoLng)
                self.path.add(CLLocationCoordinate2D(latitude: firstCoLat, longitude: firstCoLng))
                
                let secCo = firstC["southwest"] as! [String: Any]
                print(secCo)
                let secCoLat = secCo["lat"] as! Double
                print(secCoLat)
                let secCoLng = secCo["lng"] as! Double
                print(secCoLng)
                self.path.add(CLLocationCoordinate2D(latitude: secCoLat, longitude: secCoLng))
                //print(dict)
                //let dict2 = dict["overview_polyline"] as! [String: Any]
                let dict2 = (dict["legs"] as! NSArray).mutableCopy() as! NSMutableArray
                //self.makeRoute(route: dict2)
                let aye = dict2[0] as! [String: Any]
                //print(aye)
                let stake = (aye["steps"] as! NSArray).mutableCopy() as! NSMutableArray
                self.makeRoute(route: stake)
               // completionHandler(data as? NSDictionary, nil)
            case .failure(let error):
                print(error)
                //completionHandler(nil, error as NSError?)
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
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        view = mapView
//        
//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView

        // Do any additional setup after loading the view.
        
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self as! CLLocationManagerDelegate
        //locationManager.startUpdatingLocation()

        //locationManager.delegate = mapDisplay as! CLLocationManagerDelegate
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
        matchUsers()
        getThis()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if self.restorationIdentifier == "hitcher" {
            self.hitchOrDrive = "hitch"
            //view.sto
            
        } else if self.restorationIdentifier == "driver" {
            self.hitchOrDrive = "drive"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Populate the address form fields.
    func fillAddressForm(place: GMSPlace) {
//        address_line_1.text = street_number + " " + route
//        city.text = locality
//        state.text = administrative_area_level_1
//        if postal_code_suffix != "" {
//            postal_code_field.text = postal_code + "-" + postal_code_suffix
//        } else {
//            postal_code_field.text = postal_code
//        }
//        country_field.text = country
//        
//        // Clear values for next time.
//        street_number = ""
//        route = ""
//        neighborhood = ""
//        locality = ""
//        administrative_area_level_1  = ""
//        country = ""
//        postal_code = ""
//        postal_code_suffix = ""
       // present(self, animated: true, completion: nil)
        
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
        //        marker?.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker?.position = place.coordinate
        marker?.title = place.description
        //marker?.snippet = currentLocation.n
        marker?.map = mapView
        
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        //view.addSubview(marker)

        //locationManager.delegate = self as! CLLocationManagerDelegate
        //locationManager.startUpdatingLocation()
        
        //locationManager.delegate = mapDisplay as! CLLocationManagerDelegate
        //placesClient = GMSPlacesClient.shared()

        
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


