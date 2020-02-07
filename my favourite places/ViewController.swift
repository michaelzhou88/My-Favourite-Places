//
//  ViewController.swift
//  My Favourite Places
//
//  Created by Zhou, Michael on 01/11/2018.
//  Copyright © 2018 Zhou, Michael. All rights reserved.
//

// Imported libraries
import UIKit
import MapKit
import CoreData

// Declaration of global variables
let appDelegate = UIApplication.shared.delegate as! AppDelegate
var context: NSManagedObjectContext?

class ViewController: UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialising the latitude and longitude variable values
        let lat : String = "53.406566"
        let lon : String = "-2.966531"
        // Converting the values to the double data type
        guard let latitude = Double(lat) else { return }
        guard let longitude = Double(lon) else { return }
        // Defining the span as the width and height of the map region
        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        // Latitude and longitude values will be set to the Ashton building by default
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // Defining the geographic region based on span and coordinate
        let region = MKCoordinateRegion(center: coordinate, span: span)
        // Changes the currently visible region and optionally animates the change
        self.map.setRegion(region, animated: true)
        // Creates gesture recogniser
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecognizer:)))
        // The minimum period fingers must press on the view for the gesture to be recognized
        uilpgr.minimumPressDuration = 2
        // Attaches a gesture recognizer to the view
        map.addGestureRecognizer(uilpgr)
        
        context = appDelegate.persistentContainer.viewContext
        
        guard currentPlace != -1 else { return }
        guard entries.count > currentPlace else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        
        request.returnsObjectsAsFaults = false
        
        do {
            // This will cast a list of objects from the core data request
            let results = try context?.fetch(request)
            // If else conditional statement to check if there are results available
            if (results?.count)! > 0 {
                var index = 0
                // For loop will iterate through each object represented in the core data
                for objects in results! {
                    if (index == currentPlace) {
                        guard let name = (objects as! Location).name else { return }
                        guard let lat = (objects as! Location).lat else { return }
                        guard let lon = (objects as! Location).long else { return }
                        guard let latitude = Double(lat) else { return }
                        guard let longitude = Double(lon) else { return }
                        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let region = MKCoordinateRegion(center: coordinate, span: span)
                        self.map.setRegion(region, animated: true)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = name
                        self.map.addAnnotation(annotation)
                        // Prints out the total number of pinned locations saved in the core data
                        print(currentPlace)
                        
                        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecognizer:)))
                        uilpgr.minimumPressDuration = 2
                        map.addGestureRecognizer(uilpgr)
                    }
                    // Increment index by 1
                    index += 1
                }
                // Prints out the number of entries in the console
                print(entries.count)
            } else {
                // If nothing saved in core data then prints to the console that there are no results
                print("No results found")
            }
        } catch {
            // In the event of an error, it will print an error message
            print("Results could not be fetched")
        }
    }

    // Method to enable gesture recognition
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        // If statement to check if the gesture recogniser has been touched
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            // Print to console to indicate a long press has been initiated
            print("-----\nLong Press\n-----")
            // Returns the point computed as the location in the given view of the gesture
            let touchPoint = gestureRecognizer.location(in: self.map)
            // Sets the new coordinate values of newly pinned location
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            // Prints out coordinates of newly pinned location
            print(newCoordinate)
            // Holds latitude and longitude values of the newly pinned location
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            // Initialisation of title of newly pinned location
            var title = ""
            // Submits a reverse-geocoding request for the newly pinned location
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let placemark = placemarks?[0] {
                        if placemark.subThoroughfare != nil {
                            title += placemark.subThoroughfare! + " "
                        }
                        if placemark.thoroughfare != nil {
                            title += placemark.thoroughfare!
                        }
                    } }
                // If the location that the user has pinned down is unknown ...
                if title == "" {
                    // Set the title of the unknown pinned location to be
                    title = "Added \(NSDate())"
                }
                // Declaration of annotation as an object tied to a specified point on the map
                let annotation = MKPointAnnotation()
                // Sets the coordinate values of the annotation
                annotation.coordinate = newCoordinate
                // Sets the title of the annotation
                annotation.title = title
                // Adds the specified annotation to the map view
                self.map.addAnnotation(annotation)
                // Appends the co-ordinates of the new pinned locations
                places.append(["name":title, "lat": String(newCoordinate.latitude), "lon": String(newCoordinate.longitude)])
                // Creates, configures, and returns an instance of the class for the "Location" entity
                let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context!) as! Location
                // Sets the value of the title as the value for the key "name" from the "Location" entity
                newLocation.setValue(title, forKey: "name")
                // Sets the value of the latitude as the value for the key "lat" from the "Location" entity
                newLocation.setValue(String(newCoordinate.latitude), forKey: "lat")
                // Sets the value of the longitude as the value for the key "long" from the "Location" entity
                newLocation.setValue(String(newCoordinate.longitude), forKey: "long")
                
                do {
                    // Saves the changes that were made
                    try context?.save()
                    // Appends the updated values made to an array after new location has been pinned
                    entries.append(newLocation)
                    // Prints to console to show new location has been saved
                    print("New location has been saved")
                } catch {
                    // In the event of an error, a message will be printed to the console to inform of it
                    print("Save Failed")
                }
            }) }
    }
    
    // Outlet property for map
    @IBOutlet weak var map: MKMapView!
}

