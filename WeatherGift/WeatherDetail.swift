//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Cooper Schmitz on 3/21/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import Foundation

//everything in WeatherLocation PLUS anything we add below
class WeatherDetail: WeatherLocation {
    
    struct Result: Codable {
        var timezone: String
        var currently: Currently
        var daily: Daily
    }
    
    struct Currently: Codable {
        var temperature: Double
        
    }
    
    struct Daily: Codable {
        var summary: String
        var icon: String
    }
    
    
    var timezone = ""
    var temperature = 0
    var summary = ""
    var dailyIcon = ""
    
    func getData(completed: @escaping () -> () ){
        let coordinates = "\(latitude),\(longitude)"
        let urlString = "\(APIurls.darkSkyURL)\(APIKey.darkSkyKey)/\(coordinates)"
        print("🕸: We are accessing url \(urlString)")
        
        //create URL
        guard let url = URL(string: urlString) else {
            print("😡ERROR: Could not create URL from \(urlString)")
            completed()
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
                let result = try JSONDecoder().decode(Result.self, from: data!)
                self.timezone = result.timezone
                self.temperature = Int(result.currently.temperature.rounded())
                self.summary = result.daily.summary
                self.dailyIcon = result.daily.icon
                
                
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        
        task.resume()
    }
    
    
    
    
}
