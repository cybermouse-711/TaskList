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
        taskList = viewContex.fetchData()
    }
    
    // MARK: - Private Metods
 
    private func addNewTask() {
        showAlert(withTitle: "New Task", withMessage: "What do you want to do?")
    }
    
    private func createTask(at indexPath: IndexPath) {
        let text = taskList[indexPath.row].title ?? "Task"
        changeAlert(withTitle: "Change Task", withMessage: "What do you want to change?", andTextField: text, for: indexPath)
    }
 /*
    private func save(_ taskName: String) {
        let task = Task(context: viewContex)
        task.title = taskName
        taskList.append(task)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        context.saveContext()
    }
    
    private func change(_ taskName: String, _ indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        print(indexPath)
        taskList.remove(at: indexPath.row)
        print(indexPath)
        viewContex.delete(task)
        
        let newTask = Task(context: viewContex)
        newTask.title = taskName
        taskList.insert(newTask, at: indexPath.row)
        tableView.reloadData()
        
        context.saveContext()
    }
    
    private func delete(_ task: Task, _ indexPath: IndexPath) {
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        viewContex.delete(task)
        
        context.saveContext()
    } */
}

// MARK: - Alerts
private extension TaskListViewController {
    func showAlert(withTitle title: String, withMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [weak self] _ in
            guard let textTask = alert.textFields?.first?.text, !textTask.isEmpty else { return }
            self?.viewContex.save(textTask, comletion: { [unowned self] task in
                self?.taskList.append(task)
                let indexPath = IndexPath(row: (self?.taskList.count ?? 0) - 1, section: 0)
                self?.tableView.insertRows(at: [indexPath], with: .automatic)
            }
            )
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Task"
        }
        present(alert, animated: true)
    }
    
    func changeAlert(withTitle title: String, withMessage message: String, andTextField textField: String, for indexPath: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [weak self] _ in
            guard let textTask = alert.textFields?.first?.text, !textTask.isEmpty else { return }
            self?.viewContex.change(textTask, comletion: { [unowned self] _ in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { oldTextField in
            oldTextField.text = textField
        }
        present(alert, animated: true)
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
        createTask(at: indexPath)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
