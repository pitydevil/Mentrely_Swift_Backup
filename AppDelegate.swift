//
//  AppDelegate.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 21/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import FirebaseAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    let defaults = UserDefaults.standard
    var window : UIWindow?
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().tintColor = UIColor("#FF9300")
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: UIUserNotificationType(rawValue: UIUserNotificationType.sound.rawValue|UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue), categories: nil))
      
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
       
        let isEnabled = defaults.bool(forKey: "checkNotif")
        if isEnabled == true {
            let localNotification : UILocalNotification = UILocalNotification()
            localNotification.alertTitle = "We Missed You"
            localNotification.alertBody = "Come back here, If you are still feeling unwell."
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 604.8000) as Date
            UIApplication.shared.scheduleLocalNotification(localNotification)
        } else {
            print("No Notification")
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       return GIDSignIn.sharedInstance().handle(url)
    }
 
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchTime"), object: nil)
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchTime"), object: nil)
    }
    
        // MARK: - Core Data stack
        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Mentrely")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        // MARK: - Core Data Saving support
        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
}


let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext






