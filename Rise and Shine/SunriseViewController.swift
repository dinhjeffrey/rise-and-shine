//
//  SunriseViewController.swift
//  Rise and Shine
//
//  Created by jeffrey dinh on 7/30/16.
//  Copyright © 2016 jeffrey dinh. All rights reserved.
//
import Solar
import UIKit
import CoreLocation


class SunriseViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var sunriseDateLabel: UILabel!
    @IBOutlet weak var timeOffsetPicker: UIDatePicker!
    @IBOutlet weak var deltaButton: UIButton!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func deltaButtonPressed(sender: UIButton) {
        if sender.titleLabel?.text == "+" {
            deltaButton.setTitle("-", forState: .Normal)
            print("a")
        } else {
            deltaButton.setTitle("+", forState: .Normal)
            print("b")
        }
    }
    @IBAction func timeOffsetChanged(sender: UIDatePicker) {
        
    }
    
    // MARK: - Constants and variables
    var locationManager: CLLocationManager!
    var sunrise = NSDate()
    let calender = NSCalendar.currentCalendar()
    
    
    
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let offset = NSUserDefaults.standardUserDefaults().objectForKey("sunriseOffset") as? NSDate {
            timeOffsetPicker.date = offset
        }
//        let userCalender = NSCalendar.currentCalendar()
//        let hourMinuteComponents: NSCalendarUnit = [.Hour, .Minute]
//        let timeDifference = userCalender.components(
//            hourMinuteComponents,
//            fromDate: sunrise,
//            toDate: <#T##NSDate#>,
//            options: []
//        )
        

        
        if (CLLocationManager.locationServicesEnabled()) {
            print("enabled")
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            print("not enabled")
        }
        
        
        
        
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        let timeZone = NSTimeZone.defaultTimeZone()
        
        let solar = Solar(
                          withTimeZone: timeZone,
                          latitude: location.coordinate.latitude,
                          longitude: location.coordinate.longitude
        )
        self.sunrise = solar!.sunrise!
        
        let mediumDate = sunrise.mediumDate
        
        sunriseDateLabel.text = mediumDate
        
        let comp = calender.components([.Hour, .Minute], fromDate: timeOffsetPicker.date)
        var delta = comp.hour * 3600 + comp.minute * 60
        if self.deltaButton.titleLabel?.text == "-" {
            delta *= -1
        }
        let sunriseDelta = NSDate(timeInterval: Double(delta), sinceDate: sunrise)
        alarmTimeLabel.text = sunriseDelta.mediumDate
        
        //print("delta: \(delta)")
        
        //print(sunrise?.mediumDate)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(timeOffsetPicker.date, forKey: "sunriseOffset")
    }
    
    
    
    
}
extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

extension NSDate {
    struct Formatter {
        static let mediumDate = NSDateFormatter(dateFormat: "M/dd/yyy, H:mm")
        static let time = NSDateFormatter(dateFormat: "H:mm")
    }
    var mediumDate: String {
        return Formatter.mediumDate.stringFromDate(self)
    }
    var time: String {
        return Formatter.time.stringFromDate(self)
    }
}

