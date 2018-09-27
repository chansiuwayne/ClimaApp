//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SVProgressHUD



class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate{
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "8926847d73330e32ba25a9b1eeae6bdf"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let wertherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        //TODO:Set up the location manager here.
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWatherData(url:String, parameters:[String:String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
                if response.result.isSuccess {
                    print("Success! Got the weather data")
                    
                    let weatherJSON : JSON = JSON(response.result.value!)
                    
                    self.updateWeatherData(json: weatherJSON)
                    
                    print(weatherJSON)
            
                }
                else {
                    print("Error \(String(describing: response.result.error))")
                    self.cityLabel.text = "Connectrion Issues"
                }
        }
        
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData( json:JSON ){
        
        if let tempResult = json["main"]["temp"].double {
        wertherDataModel.temperature = Int(tempResult - 273.15)
        
        wertherDataModel.city = json["name"].stringValue
        
        wertherDataModel.condition = json["weather"][0]["id"].intValue
        
        wertherDataModel.weatherIconName = wertherDataModel.updateWeatherIcon(condition: wertherDataModel.condition)
            
        updateUIWithWeatherDate()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }


    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherDate() {
        
        cityLabel.text = wertherDataModel.city
        temperatureLabel.text = "/(wertherDataModel.temperature)"
        weatherIcon.image = UIImage(named: wertherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1 ]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String: String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWatherData(url: WEATHER_URL, parameters: params)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWatherData(url: WEATHER_URL, parameters: params)
    }
    
    //write the prepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
}


