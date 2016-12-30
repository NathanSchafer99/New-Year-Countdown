//
//  NotificationViewController.swift
//  New Year Countdown
//
//  Created by Nathan Schafer on 28/12/16.
//  Copyright © 2016 Nathan Schafer. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationViewController: UIViewController {
    
    var isGrantedNotificationAccess:Bool = false
    
    var globalTitleArray = NSArray()
    
    var globalDateArray = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
                if self.isGrantedNotificationAccess {
                    self.getTitles()
                    self.getDates()
                    self.setupNotifications()
                    self.dismiss(animated: false, completion: nil)
                    DispatchQueue.main.async {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "mainView") as! ViewController
                        self.present(nextViewController, animated:true, completion:nil)
                    }
                }
                else {
                    UIApplication.shared.open(NSURL(string:UIApplicationOpenSettingsURLString)! as URL,completionHandler: nil)
                }
                
        })
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
