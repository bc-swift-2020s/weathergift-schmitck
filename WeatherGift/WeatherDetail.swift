//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Cooper Schmitz on 3/21/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    //just created a DATEFORMATTER
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
}()


private let hourlyFormatter: DateFormatter = {
    //just created a DATEFORMATTER
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h aaaa"
    return dateFormatter
}()

struct DailyWeatherData {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

struct HourlyWeatherData {
    var hour: String
    var hourlyIcon: String
    var hourlyTemperature: Int
    var hourlyPrecipProbability: Int
}

//everything in WeatherLocation PLUS anything we add below
class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable {
        var timezone: String
        var currently: Currently
        var daily: Daily
        var hourly: Hourly
    }
    
    private struct Currently: Codable {
        var temperature: Double
        var time: TimeInterval
        
    }
    
    private struct Daily: Codable {
        var summary: String
        var icon: String
        var data: [DailyData]
    }
    
    private struct Hourly: Codable {
        var data: [HourlyData]
    }
    
    private struct DailyData: Codable {
        var icon: String
        var time: TimeInterval
        var summary: String
        var temperatureHigh: Double
        var temperatureLow: Double
    }
    
    private struct HourlyData: Codable {
        var icon: String
        var time: TimeInterval
        var temperature: Double
        var precipProbability: Double
    }
    
    var timezone = ""
    var temperature = 0
    var currentTime = 0.0
    var summary = ""
    var dailyIcon = ""
    var dailyWeatherData: [DailyWeatherData] = []
    var hourlyWeatherData: [HourlyWeatherData] = []
    
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
                self.currentTime = result.currently.time
                self.temperature = Int(result.currently.temperature.rounded())
                self.summary = result.daily.summary
                self.dailyIcon = result.daily.icon
                
                for index in 0..<result.daily.data.count {
                    let weekdayDate = Date(timeIntervalSince1970: result.daily.data[index].time)
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let dailyWeekday = dateFormatter.string(from: weekdayDate)
                    let dailyIcon = result.daily.data[index].icon
                    let dailySummary = result.daily.data[index].summary
                    let dailyHigh = result.daily.data[index].temperatureHigh
                    let dailyLow = result.daily.data[index].temperatureLow
                    let dailyWeather = DailyWeatherData(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: Int(dailyHigh.rounded()), dailyLow: Int(dailyLow.rounded()))
                    self.dailyWeatherData.append(dailyWeather)
                    print("Day: \(dailyWeather.dailyWeekday), High: \(dailyWeather.dailyHigh), Low: \(dailyWeather.dailyLow)")
                }
                
                for index in 0..<result.hourly.data.count {
                    let hour = Date(timeIntervalSince1970: result.hourly.data[index].time)
                    hourlyFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let hourlyTime = hourlyFormatter.string(from: hour)
                    let hourlyTemperature = result.hourly.data[index].temperature
                    let precipProb = result.hourly.data[index].precipProbability
                    let hourlyIcon = result.hourly.data[index].icon
                    let hourly = HourlyWeatherData(hour: hourlyTime, hourlyIcon: hourlyIcon, hourlyTemperature: Int(hourlyTemperature), hourlyPrecipProbability: Int(precipProb*100))
                    self.hourlyWeatherData.append(hourly)
                    print("Hour: \(hourly.hour), Temp: \(hourly.hourlyTemperature), Precipitation: \(hourly.hourlyPrecipProbability)% Icon: \(hourly.hourlyIcon)")
                }
                
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        
        task.resume()
    }
    
    
    
    
}
