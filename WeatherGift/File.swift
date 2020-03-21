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
    
    //NEED TO CALL THIS GET DATA FUNCTION
}
