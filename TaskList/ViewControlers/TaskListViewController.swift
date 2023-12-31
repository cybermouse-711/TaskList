//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit

// MARK: - UITableViewController
final class TaskListViewController: UITableViewController {
    
    // MARK: - Private Property
    private let cellID = "task"
    private var taskList: [Task] = []
    
    // MARK: - Singlton
    private var viewContex = StorageManager.shared

    // MARK: - Override Metods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    // MARK: - Private Metods
    private func addNewTask() {
        showAlert()
    }

    private func fetchData() {
        viewContex.fetchData { [unowned self] result in
            switch result {
            case .success(let taskList):
                self.taskList = taskList
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func save(_ taskName: String) {
        viewContex.save(taskName) { task in
            taskList.append(task)
            tableView.insertRows(at: [IndexPath(row: (self.taskList.count - 1), section: 0)],
                                 with: .automatic)
        }
    }
    
    private func change(_ taskName: String, _ indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        viewContex.change(taskName, task)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTask()
                tableView.reloadData()
            }
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            viewContex.delete(task)
        } else if editingStyle == .insert {}
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Alert
extension TaskListViewController {
    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {
        let alertFactory = AlertController(
            userAction: task != nil ? .create : .save,
            taskTitle: task?.title
        )
        
        let alert = alertFactory.createAlert { [weak self] taskName in
            if let task, let completion {
                self?.viewContex.change(taskName, task)
                completion()
                return
            }
            self?.save(taskName)
        }
        present(alert, animated: true)
    }
}
