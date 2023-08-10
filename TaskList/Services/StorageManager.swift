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
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let contex: NSManagedObjectContext
    
    private init() {
        contex = persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support
    func saveContext() {
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
    func fetchData(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let task = try contex.fetch(fetchRequest)
            completion(.success(task))
        } catch let error {
            completion(.failure(error))
        }
    }
                       
    func save(_ taskName: String, comletion: (Task) -> Void) {
        let task = Task(context: contex)
        task.title = taskName
        comletion(task)
        saveContext()
    }
    
    func change(_ taskName: String, _ task: Task)  {
        task.title = taskName
        saveContext()
    }
    
    func delete(_ task: Task) {
        contex.delete(task)
        saveContext()
    }
}
