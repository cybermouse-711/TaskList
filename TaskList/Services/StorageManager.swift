//
//  StorageManager.swift
//  TaskList
//
//  Created by Елизавета Медведева on 08.08.2023.
//

import CoreData
import UIKit

// MARK: - StorageManager
final class StorageManager {
    
    // MARK: - Singlton
    static let shared = StorageManager()
    
    private init() {}
    
    
    // MARK: - Core Data stack
   var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data Saving support
    private func saveContext() {
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
    
    // MARK: - Metods
    func fetchData() -> [Task] {
        let context = persistentContainer.viewContext
        let fetchRequest = Task.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    func saveData(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
