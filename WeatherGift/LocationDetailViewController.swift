//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Cooper Schmitz on 3/19/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import UIKit
import CoreLocation

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
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  
  var locationIndex = 0
  var weatherDetail: WeatherDetail!
  var locationManager: CLLocationManager!
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    //viewController's main view is about to or did appear
    //override means that were odifying a method that is a part of the PARENTS class
    super.viewWillAppear(animated)
    print("**WillAppear executing for LocationIndex = \(locationIndex)")
    tableView.dataSource = self
    tableView.delegate = self
    collectionView.dataSource = self
    collectionView.delegate = self
    if locationIndex == 0 {
      getLocation()
    }
    updateUserInterface()
  }
  
  
  
  
  func updateUserInterface() {
    //get first element in viewController and then makes it rootViewController
    let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
    //current posiition of the current page in the array of indeces
    let weatherLocation = pageViewController.weatherLocations[locationIndex]
    weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
    
    
    pageControl.numberOfPages = pageViewController.weatherLocations.count
    pageControl.currentPage = locationIndex
    //escaping enclosure NEEDED
    weatherDetail.getData {
      DispatchQueue.main.async {
        dateFormatter.timeZone = TimeZone(identifier: self.weatherDetail.timezone)
        let usableDate = Date(timeIntervalSince1970: self.weatherDetail.currentTime)
        self.dateLabel.text = dateFormatter.string(from: usableDate)
        self.placeLabel.text = self.weatherDetail.name
        self.temperatureLabel.text = "\(self.weatherDetail.temperature)º"
        self.summaryLabel.text = self.weatherDetail.summary
        self.imageView.image = UIImage.init(named: "\(self.weatherDetail.dailyIcon)")
        self.tableView.reloadData()
        self.collectionView.reloadData()
      }
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowList" {
      let destination = segue.destination as! LocationListViewController
      let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
      
      destination.weatherLocations = pageViewController.weatherLocations
    }
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

extension LocationDetailViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return weatherDetail.dailyWeatherData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DailyTableViewCell", for: indexPath) as! DailyWeatherCell
    cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
}

extension LocationDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return weatherDetail.hourlyWeatherData.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCollectionViewCell
    hourlyCell.hourlyWeather = weatherDetail.hourlyWeatherData[indexPath.row]
    return hourlyCell
  }
  
  
}
extension LocationDetailViewController: CLLocationManagerDelegate {
  
  func getLocation(){
    //creating a CLLocationManager will automatically check authorization
    locationManager = CLLocationManager()
    locationManager.delegate = self
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("👮‍♀️Checking authentication status.")
    handleAuthenticationStatus(status: status)
  }
  
  func handleAuthenticationStatus(status: CLAuthorizationStatus) {
    //CLAuthStatus is an ENUMERATED TYPE
    switch status {
      
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .restricted:
      self.oneButtonAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in the app.")
    case .denied:
      showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.requestLocation()
    @unknown default:
      print("*Unknown case of status!")
    }
  }
  
  
  func showAlertToPrivacySettings(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
      print("Something went wrong with getting the openSettingsURLString")
      return
    }
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
      UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(settingsAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
    
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let currentLocation = locations.last ?? CLLocation()
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
      var locationName = ""
      if placemarks != nil {
        let placemark = placemarks?.last
        locationName = placemark?.name ?? "Parts Unknown"
      } else {
        locationName = "Could not find location."
      }
      print("Location name is \(locationName)")
      let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
      //current posiition of the current page in the array of indeces
      
      pageViewController.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.latitude
      pageViewController.weatherLocations[self.locationIndex].longitude = currentLocation.coordinate.longitude
      pageViewController.weatherLocations[self.locationIndex].name = locationName 
      self.updateUserInterface()
    }
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    //TODO: FINISH THIS
  }
}
