//
//  DailyWeatherCell.swift
//  WeatherGift
//
//  Created by Cooper Schmitz on 3/28/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import UIKit

class DailyWeatherCell: UITableViewCell {

    @IBOutlet weak var dailyImageView: UIImageView!
    @IBOutlet weak var dailyWeekdayLabel: UILabel!
    @IBOutlet weak var dailySummaryView: UITextView!
    @IBOutlet weak var dailyHighLabel: UILabel!
    @IBOutlet weak var dailyLowLabel: UILabel!
    var dailyWeather: DailyWeatherData! {
        didSet {
            dailyImageView.image = UIImage(named: dailyWeather.dailyIcon)
                  dailyWeekdayLabel.text = dailyWeather.dailyWeekday
                  dailySummaryView.text = dailyWeather.dailySummary
                  dailyHighLabel.text = "\(dailyWeather.dailyHigh)" + "˚"
                  dailyLowLabel.text = "\(dailyWeather.dailyLow)" + "˚"
        }
    }
  
    
}
