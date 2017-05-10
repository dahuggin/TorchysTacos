//
//  ViewController.swift
//  TorchysTacos
//
//  Created by Daniel Huggins on 1/10/16.
//  Copyright © 2016 Daniel Huggins. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBAction func findTorchys(sender:AnyObject) {
        let annotationsToRemove = mapView.annotations
        mapView.removeAnnotations(annotationsToRemove)
        self.displayNearestLocation()
    }
    
    @IBAction func showAllTorchys(sender: AnyObject) {
        let annotationsToRemove = mapView.annotations
        mapView.removeAnnotations(annotationsToRemove)
        self.distanceLabel.text = ""
        for (location, address, latitude, longitude) in austinLocations {
            let lat = NSString(string: latitude).doubleValue
            let long = NSString(string: longitude).doubleValue
            let torchyLocation = CLLocation(latitude: lat, longitude: long)
            let locationPinCoord = CLLocationCoordinate2D(latitude: torchyLocation.coordinate.latitude, longitude: torchyLocation.coordinate.longitude)
            let torchyPin = MKPointAnnotation()
            torchyPin.coordinate = locationPinCoord
            torchyPin.title = location
            torchyPin.subtitle = address
            mapView.addAnnotation(torchyPin)
        }
    }
    
    override func viewWillAppear(animated: Bool) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let userLocation = locationManager.location
        let location = CLLocationCoordinate2DMake((userLocation!.coordinate.latitude), (userLocation!.coordinate.longitude))
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayLocationInfo(placemark: CLPlacemark)
    {
        print(placemark.locality)
        print(placemark.postalCode)
        print(placemark.administrativeArea)
        print(placemark.country)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    func displayNearestLocation() {
        
        let (name, address, lat, long) = findNearestLocation()
        let latitude = (lat as NSString).doubleValue
        let longitude = (long as NSString).doubleValue
        let torchyLocation = CLLocation(latitude: latitude, longitude: longitude)
        let center = CLLocationCoordinate2D(latitude: torchyLocation.coordinate.latitude, longitude: torchyLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.02, 0.02))
        self.mapView.setRegion(region, animated: true)
        let locationPinCoord = CLLocationCoordinate2D(latitude: torchyLocation.coordinate.latitude, longitude: torchyLocation.coordinate.longitude)
        let torchyPin = MKPointAnnotation()
        torchyPin.coordinate = locationPinCoord
        torchyPin.title = name
        torchyPin.subtitle = address
        mapView.addAnnotation(torchyPin)
        mapView.selectAnnotation(torchyPin, animated: true)
    }
    
    func findNearestLocation() -> (String, String, String, String) {
        var distanceArray : [CLLocationDistance] = []
        var userLocation = locationManager.location
        for (location, address, latitude, longitude) in austinLocations {
            var lat = NSString(string: latitude).doubleValue
            var long = NSString(string: longitude).doubleValue
            var testLocation = CLLocation(latitude: lat, longitude: long)
            var testDistance = userLocation?.distanceFromLocation(testLocation)
            distanceArray.append(testDistance!)
        }
        
        var lowestDistance :CLLocationDistance = 7000000000
        var lowestDistanceIndex = 0
        
        for value in distanceArray {
            if value < lowestDistance {
                lowestDistance = value
                lowestDistanceIndex = distanceArray.indexOf(lowestDistance)!
            }
        }
        
        lowestDistance = round(lowestDistance / 1609.344 * 100)/100
        self.distanceLabel.text = "\(lowestDistance) miles!"
        let lowestDistanceInfo = austinLocations[lowestDistanceIndex]
        return lowestDistanceInfo
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        let pinLocation = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        let userLocation = locationManager.location
        var selectedDistance:CLLocationDistance = (userLocation!.distanceFromLocation(pinLocation))
        selectedDistance = Double(round(selectedDistance / 1609.344 * 100)/100)
        self.distanceLabel.text = "\(selectedDistance) miles!"
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.distanceLabel.text = ""
    }
    
    
    let austinLocations = [
        ("South Congress", "1822 S. Congress Ave.", "30.2454780", "-97.7516320"),
        ("Trailer Park", "1311 South First St.", "30.2507550", "-97.7542920"),
        ("UT", "2801 Guadalupe St.", "30.2936780", "-97.7417260"),
        ("Round Rock", "2150 E. Palm Valley Blvd.", "30.5186140", "-97.6519210"),
        ("Burnet", "5119 Burnet Rd.", "30.3233780", "-97.7392260"),
        ("Meuller", "1801 E. 51st St.", "30.3015020", "-97.6996580"),
        ("Arbor Trails", "4301 W William Cannon Rd.", "30.2188430", "-97.8430970"),
        ("Spicewood", "4211 Spicewood Springs Blvd.", "30.3707340", "-97.7562730"),
        ("South Lamar", "3005 S. Lamar Blvd.", "30.2413150", "-97.7835970"),
        ("San Marcos", "301 N. Guadalupe St.", "29.8844450", "-97.9420060"),
        ("Cedar Park", "1468 E. Whitestone Blvd.", "30.5266270", "-97.8088790"),
        ("South 1st @ El Paso", "2809 South First St.", "30.2367570", "-97.7628020"),
        ("Anderson Mill", "11521 Ranch Road 620", "30.4524280", "-97.8280580")
    ]


}

