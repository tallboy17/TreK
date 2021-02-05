//
//  Alerts.swift
//  TreK
//
//  Created by Arjun Maganti on 1/31/21.
//

import Foundation
import UserNotifications
import NotificationBannerSwift


class Alerts: NSObject, UNUserNotificationCenterDelegate {
    
  let alertCenter = UNUserNotificationCenter.current()

    override init() {
        super.init()
        
        alertCenter.delegate = self

    }
    
    func requestNotificationPermission(){
        
        alertCenter.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }

            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
                print ("Alert notication Enabled")
            } else {
                // Schedule a notification with a badge and sound.
            }
        }
    }
    
    func requestNotifications(){
        print("request Notification")
        alertCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                // Handle the error here.
                print(error)
            }
            
          
        }
    }
    
    func showAlert(title:String, subtitle:String){
        print("Show Notification")
        
        /*
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let message = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger:trigger)
        
        alertCenter.add(message)
        */
        
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .info)
        banner.show(bannerPosition: .bottom)
        banner.show()
       
    }
    
}
