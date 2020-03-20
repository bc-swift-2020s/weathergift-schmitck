//
//  File.swift
//  WeatherGift
//
//  Created by Cooper Schmitz on 3/9/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    //initialize
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getData(){
        let coordinates = "\(latitude),\(longitude)"
        let urlString = "\(APIurls.darkSkyURL)\(APIKey.darkSkyKey)/\(coordinates)"
        print("🕸: We are accessing url \(urlString)")
        
        //create URL
        guard let url = URL(string: urlString) else {
            print("😡ERROR: Could not create URL from \(urlString)")
            return
        }
        let session = URLSession.shared
        
        //get data with task
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
                 //note: three are some additional things that coudl go wrong, but we should not experience them, so we'll ignore testing
            
            //deal with the data
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print("\(json)")
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
        }
        
        
        task.resume()
                
    }
    //NEED TO CALL THIS GET DATA FUNCTION
}
