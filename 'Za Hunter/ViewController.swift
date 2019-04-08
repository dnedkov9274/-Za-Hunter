//
//  ViewController.swift
//  'Za Hunter
//
//  Created by Dennis Jivko Nedkov on 4/3/19.
//  Copyright © 2019 John Hersey High School. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var pizza: [MKMapItem] = []
    
    var initalRegion:MKCoordinateRegion!
    var isInitialMapLoad = true
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isInitialMapLoad{
            initalRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: mapView.region.span)
            isInitialMapLoad = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation){
            return nil
        }
       let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = UIImage(named: "pizza")
        pin.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        let secondButton = UIButton(type: .contactAdd)
        pin.leftCalloutAccessoryView = secondButton
        return pin
    }
    func mapView(_ mapView:MKMapView, annotationView view:MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        let buttonPressed = control as! UIButton
        if buttonPressed.buttonType == .contactAdd{
            mapView.setRegion(initalRegion, animated: true)
            return
        }
        var currentMapItem = MKMapItem()
        if let title = view.annotation?.title, let pizzaName = title{
            for mapItem in pizza{
                if mapItem.name == pizzaName{
                    currentMapItem = mapItem
                }
            }
        }
        let placeMark = currentMapItem.placemark
        let address = placeMark.addressDictionary
        //print(address["Street"]!)
        if let url = currentMapItem.url {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    
    
        func locationManager (_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            currentLocation = locations[0]
            //print(currentLocation)
            
        }
    
    @IBAction func whenZoomButtonPressed(_ sender: Any) {
        let center = currentLocation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func whenSearchButtonPressed(_ sender: Any) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Pizza"
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else{
                return
            }
            for mapItem in response.mapItems{
                self.pizza.append(mapItem)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
}

