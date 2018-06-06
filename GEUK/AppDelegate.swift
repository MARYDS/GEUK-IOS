//
//  AppDelegate.swift
//  GEUK
//
//  Created by Mary Forde on 06/02/2017.
//  Copyright © 2017 Mary Forde. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private static let modelName = "GEUK"
    private static let version = "V1.2"
    private var key = ""
    static var fatalErrFound = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Check if database is installed, if not - install it
        key = "databaseLoaded" + AppDelegate.version
        let databaseLoaded = UserDefaults.standard.bool(forKey: key)
        if !databaseLoaded {
            setUpDataBase()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalErrFound = true
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if AppDelegate.fatalErrFound == false {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    AppDelegate.fatalErrFound = true
                }
            }
        }
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        if AppDelegate.fatalErrFound == false {
            return self.persistentContainer.viewContext
        } else {
            return nil
        }
    }()
    
    
    // Install the database to default directory
    private func setUpDataBase() {
        
        let directory = NSPersistentContainer.defaultDirectoryURL()
        
        // Copy the .sqlite file from project to default directory
        var url = directory.appendingPathComponent(AppDelegate.modelName + ".sqlite")
        var suppliedDatabaseURL = Bundle.main.url(forResource: AppDelegate.modelName, withExtension: "sqlite")!
        _ = try? FileManager.default.removeItem(at: url)
        do {
            try FileManager.default.copyItem(at: suppliedDatabaseURL, to: url)
        } catch {
            AppDelegate.fatalErrFound = true
        }
        
        // Copy the .sqlite file from project to default directory
        url = directory.appendingPathComponent(AppDelegate.modelName + ".sqlite-shm")
        suppliedDatabaseURL = Bundle.main.url(forResource: AppDelegate.modelName, withExtension: "sqlite-shm")!
        _ = try? FileManager.default.removeItem(at: url)
        do {
            try FileManager.default.copyItem(at: suppliedDatabaseURL, to: url)
        } catch {
            AppDelegate.fatalErrFound = true
        }
        
        // Copy the .sqlite file from project to default directory
        url = directory.appendingPathComponent(AppDelegate.modelName + ".sqlite-wal")
        suppliedDatabaseURL = Bundle.main.url(forResource: AppDelegate.modelName, withExtension: "sqlite-wal")!
        _ = try? FileManager.default.removeItem(at: url)
        do {
            try FileManager.default.copyItem(at: suppliedDatabaseURL, to: url)
        } catch {
            AppDelegate.fatalErrFound = true
        }
        
        UserDefaults.standard.set(true, forKey: key)
        
    }
    
}
