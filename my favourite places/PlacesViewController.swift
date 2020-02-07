//
//  PlacesViewController.swift
//  My Favourite Places
//
//  Created by Zhou, Michael on 01/11/2018.
//  Copyright © 2018 Zhou, Michael. All rights reserved.
//

// Imported libraries
import UIKit
import CoreData

// Declaration of global variables
var places = [Dictionary<String, String>()]
var currentPlace = -1
var entries: [NSManagedObject] = []

class PlacesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a context from container
        context = appDelegate.persistentContainer.viewContext
        // Create the request of location
        let requestLocation = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        requestLocation.returnsObjectsAsFaults = false
        
        do {
            // Executes the request
            let results = try context?.fetch(requestLocation)
            
            // If statement checks that if there are results available ...
            if (results?.count)! > 0 {
                
                // For loop will iterate through each object in core data
                for objects in results! {
                    entries.append(objects as! Location)
                }
                // Prints out the number of new entries into the console
                print(entries.count)
            } else {
                // If nothing has been saved in core data then prints to the console that there are no results
                print("No results")
            }
        } catch {
            // In the event of an error, it will output an error message to the console
            print("Results couldn't be fetched")
        }
        // Refreshs the contents of the table view
        table.reloadData()
    }

    // MARK: - Table view data source

    // Returns the number of sections in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Returns the number of rows in givne section of the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return entries.count
    }
    
    // Constructs each table view cell that will be displayed
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let updatedList = entries[indexPath.row]
        cell.textLabel?.text = updatedList.value(forKeyPath: "name") as? String
        return cell
    }
    
    // Tells the delegate that the specified row is now selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentPlace = indexPath.row
        // Sends user to the "Map" view controller via the "to Map" segue
        performSegue(withIdentifier: "to Map", sender: nil)
    }
    
    // Notifies the view controller that its view was added to a view hierarchy
    override func viewDidAppear(_ animated: Bool) {
        // Centres the map on the user’s current coordinates (since the simulator doesn’t have a real GPS, it uses the Ashton Building location instead)
        if entries.count == 0 && places[0].count == 0 {
            places.remove(at: 0)
            places.append(["name":"Ashton Building", "lat": "53.406566", "lon": "-2.966531"])
            // Creates, configures and returns an instance of the class for the "Location" entity
            let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context!) as! Location
            // Sets the Ashton Building as the value for the key "name" from the "Location" entity
            newLocation.setValue("Ashton Building", forKey: "name")
            // Sets the latitude of the Ashton Buildiing as the value for the key "lat" from the "Location" entity
            newLocation.setValue("53.406566", forKey: "lat")
            // Sets the longitude of the Ashton Buildiing as the value for the key "long" from the "Location" entity
            newLocation.setValue("-2.966531", forKey: "long")
            
            do {
                // saves the changes made and prints to console
                try context?.save()
                entries.append(newLocation)
                print("Saved")
            } catch {
                // if caught, then prints to console that save failed
                print("Save Failed")
            }
        }
        // Sets the value of currentPlace to -1
        currentPlace = -1
        // Refreshes the content of the table view
        table.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Creates a request of location
            let requestLocation = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            requestLocation.returnsObjectsAsFaults = false
            
            do {
                // casts list of objects from core data request
                let results = try context?.fetch(requestLocation)
                var index = 0
                // for loop to iterate through objects in results list
                for object in results! {
                    // checks that the object has been favourited, and is the respective report selected from the table view controller
                    if (index == indexPath.row) {
                        context?.delete(object as! NSManagedObject)
                    }
                    // Increment index value by 1
                    index += 1
                }
                do {
                    // Saves deletion record of the object and
                    try context?.save()
                    // Removes the object from the array
                    entries.remove(at: indexPath.row)
                    // Performs deletion at specified row in the table view
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    // Prints out record has been deleted to console
                    print("Deleted")
                } catch {
                    // If a deletion attempt has failed, it will print an error message to the console
                    print("Deletion Failed")
                }
            } catch {
                // In the event that the results could not be fetched, it will print an error message to console
                print("Results couldn't be fetched")
            }
        }
    }
    // Outlet property for the table view
    @IBOutlet var table: UITableView!

}
