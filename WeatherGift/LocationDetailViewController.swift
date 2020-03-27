//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Cooper Schmitz on 3/19/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
    //just created a DATEFORMATTER
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d, h:mm aaa"
    return dateFormatter
}()

class LocationDetailViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var locationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //right before we update our user interface
        updateUserInterface()
    }
    
    
    func updateUserInterface() {
        //get first element in viewController and then makes it rootViewController
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        //current posiition of the current page in the array of indeces
        let weatherLocation = pageViewController.weatherLocations[locationIndex]
        let  weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
        
        
        pageControl.numberOfPages = pageViewController.weatherLocations.count
        pageControl.currentPage = locationIndex
        //escaping enclosure NEEDED
        weatherDetail.getData {
            DispatchQueue.main.async {
                dateFormatter.timeZone = TimeZone(identifier: weatherDetail.timezone)
                let usableDate = Date(timeIntervalSince1970: weatherDetail.currentTime)
                self.dateLabel.text = dateFormatter.string(from: usableDate)
                self.placeLabel.text = weatherDetail.name
                self.temperatureLabel.text = "\(weatherDetail.temperature)º"
                self.summaryLabel.text = weatherDetail.summary
                self.imageView.image = UIImage.init(named: "\(weatherDetail.dailyIcon)")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LocationListViewController
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        
        destination.weatherLocations = pageViewController.weatherLocations
    }
    
    @IBAction func unwindFromLocationListViewController(segue: UIStoryboardSegue) {
        let source = segue.source as! LocationListViewController
        locationIndex = source.selectedLocationIndex
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        pageViewController.weatherLocations = source.weatherLocations
        pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: locationIndex)], direction: .forward, animated: false, completion: nil)
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        var direction: UIPageViewController.NavigationDirection = .forward
        if sender.currentPage < locationIndex {
            direction = .reverse
        }
        pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: sender.currentPage)], direction: direction, animated: true, completion: nil)
        
    }
    
}
