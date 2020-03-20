//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Cooper Schmitz on 3/19/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var weatherLocation: WeatherLocation!
    var weatherLocations: [WeatherLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if weatherLocation == nil {
           weatherLocation = WeatherLocation(name: "Current Location", latitude: 0.0, longitude: 0.0)
        }
        weatherLocations.append(weatherLocation)
        //right before we update our user interface
        loadLocations()
        updateUserInterface()
    }
    
    func loadLocations() {
        //read data from key
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            print("WARNING: Could not load weatherLocations data")
            return
        }
        let decoder = JSONDecoder()
        //creates a local constant
        if let weatherLocations = try? decoder.decode(Array.self, from: locationsEncoded) as [WeatherLocation] {
            //points to weatherLocations in the classwide property
            //takes what we just decoded and assign that to the classwide property
            self.weatherLocations = weatherLocations
        } else {
            print("ERROR: Couldn't decode data read from user defaults")
        }
        
    }
    
    func updateUserInterface() {
        dateLabel.text = ""
        placeLabel.text = weatherLocation.name
        temperatureLabel.text = " --°"
        summaryLabel.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LocationListViewController
        destination.weatherLocations = weatherLocations
    }
    
    @IBAction func unwindFromLocationListViewController(segue: UIStoryboardSegue) {
        let source = segue.source as! LocationListViewController
        weatherLocations = source.weatherLocations
        weatherLocation = weatherLocations[source.selectedLocationIndex]
        updateUserInterface()
    }
}
