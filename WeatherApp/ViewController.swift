//
//  ViewController.swift
//  WeatherApp
//
//  Created by Katsuhiko Hayashi on 2017/07/12.
//  Copyright © 2017年 Katsuhiko Hayashi. All rights reserved.
//

import UIKit

var publicTime = ""

var area = ""
var city = ""
var prefecture = ""
var descriptionText = ""
var descriptionPublicTime = ""

struct Weather {
    var dateLabel: String
    var telop: String
    var date: String
    var minTemperatureCcelsius: String
    var maxTemperatureCcelsius: String
    var url: String
    var title: String
    var width: Int
    var height: Int
    
    init(dateLabel: String, telop: String, date: String, minTemperatureCcelsius: String, maxTemperatureCcelsius: String, url: String, title: String, width: Int, height: Int) {
        self.dateLabel = dateLabel
        self.telop = telop
        self.date = date
        self.minTemperatureCcelsius = minTemperatureCcelsius
        self.maxTemperatureCcelsius = maxTemperatureCcelsius
        self.url = url
        self.title = title
        self.width = width
        self.height = height
    }
}
var weather = [Weather]()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let areaCode = "130010" // 東京エリア
        let urlWeather = "http://weather.livedoor.com/forecast/webservice/json/v1?city=" + areaCode
        
        if let url = URL(string: urlWeather) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {(data, resp, err) in
                //print(resp!.url!)
                //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
                
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    // dataをJSONパースし、変数"getJson"に格納
                    let getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    publicTime = (getJson["publicTime"] as? String)!
                    print("\(publicTime)")
                    
                    let location = (getJson["location"] as? NSDictionary)!
                    area = (location["area"] as? String)!
                    city = (location["city"] as? String)!
                    prefecture = (location["prefecture"] as? String)!
                    print("\(area):\(city):\(prefecture)")
                    
                    let description = (getJson["description"] as? NSDictionary)!
                    descriptionText = (description["text"] as? String)!
                    descriptionPublicTime = (description["publicTime"] as? String)!
                    print("\(descriptionText):\(descriptionPublicTime)")
                    
                    let forcasts = (getJson["forecasts"] as? NSArray)!
                    for dailyForcast in forcasts {
                        let forcast = dailyForcast as! NSDictionary
                        let dateLabel = (forcast["dateLabel"] as? String)!
                        let telop = (forcast["telop"] as? String)!
                        let date = (forcast["date"] as? String)!
                        
                        let temperature = (forcast["temperature"] as? NSDictionary)!
                        let minTemperature = (temperature["min"] as? NSDictionary)
                        var minTemperatureCcelsius: String
                        if minTemperature == nil {
                            minTemperatureCcelsius = "-"
                        }else{
                            minTemperatureCcelsius = (minTemperature?["celsius"] as? String)!
                        }
                        
                        let maxTemperature = (temperature["max"] as? NSDictionary)
                        var maxTemperatureCcelsius: String
                        if maxTemperature == nil {
                            maxTemperatureCcelsius = "-"
                        }else{
                            maxTemperatureCcelsius = (maxTemperature?["celsius"] as? String)!
                        }
                        
                        let image = (forcast["image"] as? NSDictionary)!
                        let url = (image["url"] as? String)!
                        let title = (image["title"] as? String)!
                        let width = (image["width"] as? Int)!
                        let height = (image["height"] as? Int)!
                        
                        weather.append(Weather(dateLabel: dateLabel, telop: telop, date: date, minTemperatureCcelsius: minTemperatureCcelsius, maxTemperatureCcelsius: maxTemperatureCcelsius, url: url, title: title, width: width, height: height))
                        
                    }
                    for w in weather {
                        print("\(w.dateLabel):\(w.telop):\(w.telop):\(w.date):\(w.minTemperatureCcelsius):\(w.maxTemperatureCcelsius):\(w.url)")
                    }

                    
                } catch {
                    print ("json error")
                    return
                }
            })
            task.resume()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

