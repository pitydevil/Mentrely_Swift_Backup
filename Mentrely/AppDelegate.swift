//
//  AppDelegate.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 21/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import RealmSwift
import CoreData
import Firebase
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    let defaults = UserDefaults.standard

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    UITabBar.appearance().tintColor = UIColor.systemPink

    
    application.registerUserNotificationSettings(UIUserNotificationSettings(types: UIUserNotificationType(rawValue: UIUserNotificationType.sound.rawValue|UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue), categories: nil))
    FirebaseApp.configure()
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

    Database.database().isPersistenceEnabled = true
    
    let isEnabled = defaults.bool(forKey: "checkNotif")
    if isEnabled == true {
        let localNotification : UILocalNotification = UILocalNotification()
        localNotification.alertTitle = "We Missed You"
        localNotification.alertBody = "Come back here, If You Are Still Feeling Unwell."
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 604.800) as Date
        UIApplication.shared.scheduleLocalNotification(localNotification)
    } else {
        print("No Notification")
    }
    
    do {
        _ = try Realm()
    }
    catch {
        print("error iniliatizing realm \(error)")
    }

    return true
    }

    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       return GIDSignIn.sharedInstance().handle(url)
    }
 
   func applicationWillTerminate(_ application: UIApplication) {
         self.saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Diaries")
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






