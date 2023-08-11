//
//  Extension + Alert.swift
//  TaskList
//
//  Created by Елизавета Медведева on 11.08.2023.
//

import UIKit

protocol AlertProtocol {
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController
}

final class AlertController: AlertProtocol {
    let userAction: Action
    let taskTitle: String?
    
    init(userAction: Action, taskTitle: String?) {
        self.userAction = userAction
        self.taskTitle = taskTitle
    }
    
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: userAction.title,
            message: "What do you want to do?",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text else { return }
            guard !task.isEmpty else { return }
            completion(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Task"
            textField.text = self?.taskTitle
        }
        return alert
    }
}

extension AlertController {
    enum Action: String {
        case save
        case create
        
        var title: String {
            switch self {
            case .save:
                return "Save Task"
            case .create:
                return "Create Task"
            }
        }
    }
}
