//
//  PageViewController.swift
//  WeatherGift
//
//  Created by Cooper Schmitz on 3/20/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    var weatherLocations: [WeatherLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //any code to handle is going to be in this file
        self.delegate = self
        self.dataSource = self
        
        loadLocations()
        setViewControllers([createLocationDetailViewController(forPage: 0)], direction: .forward, animated: false, completion: nil)
        
    }
    
    func loadLocations() {
        //read data from key
        //make sure you can save in UserDefaults
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            //need to create first element in userArray
            print("WARNING: Could not load weatherLocations data")
            //TODO: Get User Location for the first element in weatherLocations
            weatherLocations.append(WeatherLocation(name: "", latitude: 20.20, longitude: 20.20))
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
        
        if weatherLocations.isEmpty {
            weatherLocations.append(WeatherLocation(name: "CURRENT LOCATION", latitude: 20.20, longitude: 20.20))
        }
        
    }
    
    func createLocationDetailViewController(forPage page: Int) -> LocationDetailViewController {
        //identifier is similar to when we identified a "Cell", creates a generic UIController
        //Need to downclass this to get at the properties
        let detailViewController = storyboard!.instantiateViewController(withIdentifier: "LocationDetailViewController") as! LocationDetailViewController
        //which number of array are we looking at. The page is the individual index in the array
        //This allows new pages to be made
        detailViewController.locationIndex = page
        return detailViewController
        
    }
    
}

extension PageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    //Need to downcast first, then check to see what is the first viewController, if there is a viewController to the view, then there is going to be a new viewController that is created with createLocationDetailViewController
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //swipe left to right
        //iOS Methods that call whenever a swipe occur
        if let currentViewController = viewController as? LocationDetailViewController {
            if currentViewController.locationIndex > 0 {
                return createLocationDetailViewController(forPage: currentViewController.locationIndex - 1)
            }
        }
        return nil
    }
    //Set up viewController in the backwards direction. This time we check to make sure the locationIndex is the last location in the index, which is count - 1. If not, there is one viewController that is one to the right
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //after right to left
        if let currentViewController = viewController as? LocationDetailViewController {
            //seeing if last viewController
            if currentViewController.locationIndex < weatherLocations.count - 1 {
                return createLocationDetailViewController(forPage: currentViewController.locationIndex + 1)
            }
        }
        return nil
    }
    
    
}
