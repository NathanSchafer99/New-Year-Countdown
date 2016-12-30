//
//  ViewController.swift
//  New Year Countdown
//
//  Created by Nathan Schafer on 27/12/16.
//  Copyright © 2016 Nathan Schafer. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var timeLeftLabel: UILabel!
    
    var timer = Timer()
    
    var globalTitleArray = NSArray()
    
    var globalDateArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UNUserNotificationCenter.current().delegate = self
        getTitles()
        getDates()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let currentDate = Date()
        let  calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateDisplay), userInfo: nil, repeats: true)
        }
        
        if year == 2017 {
            timer.invalidate()
            self.dismiss(animated: false, completion: nil)
            DispatchQueue.main.async {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "newYear") as! NewYearViewController
                self.present(nextViewController, animated:true, completion:nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateDisplay() {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
        
        let newYear = dateFormat.date(from: "2017-01-01 00:00")
        let currentDate = Date()
        
        let  calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        
        if year == 2017 {
            timer.invalidate()
            self.dismiss(animated: false, completion: nil)
            DispatchQueue.main.async {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "newYear") as! NewYearViewController
                self.present(nextViewController, animated:true, completion:nil)
            }
        }
        
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .full
        var timeLeft = formatter.string(from: currentDate, to: newYear!)
        timeLeft = timeLeft?.replacingOccurrences(of: ", ", with: "\n")
        
        timeLeftLabel.text = timeLeft
    }

func getTitles() {
    if let path = Bundle.main.path(forResource: "titleArray", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            {
                if let titleArray : NSArray = jsonResult["titleArray"] as? NSArray
                {
                    globalTitleArray = titleArray
                    print(globalTitleArray)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    } else {
        print("Invalid filename/path.")
    }
}

func getDates() {
    if let path = Bundle.main.path(forResource: "dateArray", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            {
                if let dateArray : NSArray = jsonResult["dateArray"] as? NSArray
                {
                    globalDateArray = dateArray
                    print(globalDateArray)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    } else {
        print("Invalid filename/path.")
    }
}

func setupNotifications() {
    
    let content = UNMutableNotificationContent()
    
    for index in 0..<globalTitleArray.count {
        content.title = "New Year Countdown"
        content.body = globalTitleArray[index] as! String
        content.sound = UNNotificationSound(named: "Audio/\(globalTitleArray[index]).mp3")
        print("Audio/\(globalTitleArray[index]).mp3")
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormat.date(from: globalDateArray[index] as! String)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        
        let identifier = String(index)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
        })
    }
}
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // some other way of handling notification
        completionHandler([.alert, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        
    }
}
