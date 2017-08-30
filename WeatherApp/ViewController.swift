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
    var img: UIImage
    var title: String
    var width: Int
    var height: Int
    
    init(dateLabel: String, telop: String, date: String, minTemperatureCcelsius: String, maxTemperatureCcelsius: String, url: String, img: UIImage, title: String, width: Int, height: Int) {
        self.dateLabel = dateLabel
        self.telop = telop
        self.date = date
        self.minTemperatureCcelsius = minTemperatureCcelsius
        self.maxTemperatureCcelsius = maxTemperatureCcelsius
        self.url = url
        self.img = img
        self.title = title
        self.width = width
        self.height = height
    }
}
var weather = [Weather]()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // UITableView を作成
        // サイズと位置調整
        tableView.frame = CGRect(
            x: 0,
            y: statusBarHeight,
            width: self.view.frame.width,
            height: self.view.frame.height - statusBarHeight
        )
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64

        // Delegate設定
        tableView.delegate = self
        
        // DataSource設定
        tableView.dataSource = self
        
        // 画面に UITableView を追加
        self.view.addSubview(tableView)
        
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
                        
                        let imgUrl = URL(string: url)
                        let imgData = try? Data(contentsOf: imgUrl!)
                        let img = UIImage(data: imgData!)
                        
                        weather.append(Weather(dateLabel: dateLabel, telop: telop, date: date, minTemperatureCcelsius: minTemperatureCcelsius, maxTemperatureCcelsius: maxTemperatureCcelsius, url: url, img: img!, title: title, width: width, height: height))
                        
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
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
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        // セルの中身を設定
        // セルの中身を設定
        if indexPath.row == 0 {
            cell.textLabel?.text = "\(prefecture)の天気"
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.text = publicTime
            cell.detailTextLabel?.textColor = .white
            cell.contentView.backgroundColor = UIColor.black
            
        } else if indexPath.row == weather.count + 1 {
            cell.textLabel?.text = descriptionText
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14);
            cell.detailTextLabel?.text = descriptionPublicTime
            
        } else {
            let row = indexPath.row - 1
            cell.textLabel?.text = "\(weather[row].dateLabel)の天気：\(weather[row].telop)"
            cell.detailTextLabel?.text = "最低気温\(weather[row].minTemperatureCcelsius)度  最高気温\(weather[row].maxTemperatureCcelsius)度"
            cell.imageView!.image = weather[row].img
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数を設定
        var ret:Int
        if weather.count == 0 {
            ret = 0
        }else{
            ret = weather.count + 2
        }
        return ret
    }
    
}

