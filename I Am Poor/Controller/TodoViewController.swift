//
//  TodoViewController.swift
//  I Am Poor
//
//  Created by Darian Mitchell on 2024/7/26.
//

import RealmSwift
import UIKit

class TodoViewController: UITableViewController {
    private let realm = try! Realm()
    var category: Category?
    var filteredTodos: Results<Todo>?
    private var token: NotificationToken?

    @IBOutlet var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodos()
    }

    func loadTodos(_ predicate: NSPredicate? = nil) {
        if let predicate {
            filteredTodos = category?.todos.filter(predicate).sorted(by: \.title)
        } else {
            filteredTodos = category?.todos.sorted(by: \.title)
        }
        tableView.reloadData()
    }

    @IBAction func addTodoPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField?
        let alertControlelr = UIAlertController(title: "Add Todo", message: nil, preferredStyle: .alert)
        alertControlelr.addTextField { field in
            textField = field
        }
        let action = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let category = self.category,
                  let text = textField?.text,
                  !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            do {
                try self.realm.write {
                    let todo = Todo(title: text)
                    category.todos.append(todo)
                }
            } catch {
                print("Failed to add new category: \(error.localizedDescription)")
            }
        }
        alertControlelr.addAction(action)
        present(alertControlelr, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        token = realm.observe({ _, _ in
            self.tableView.reloadData()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        token?.invalidate()
    }
}

// MARK: - Searchbar delegate

extension TodoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            loadTodos()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
        loadTodos(predicate)
    }
}

// MARK: - table view data source

extension TodoViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTodos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let todo = filteredTodos?[indexPath.row] {
            cell.textLabel?.text = todo.title
            cell.accessoryType = todo.done ? .checkmark : .none
        }
        return cell
    }
}

// MARK: - table view delegate

extension TodoViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let todo = filteredTodos?[indexPath.row] else { return }

        do {
            try realm.write {
                todo.done = !todo.done
            }
        } catch {
            print("Failed to update todo: \(error)")
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { _, _, _ in
            guard let todo = self.filteredTodos?[indexPath.row],
                  let index = self.category?.todos.firstIndex(of: todo) else {
                return
            }
            do {
                try self.realm.write {
                    self.category?.todos.remove(at: index)
                }
            } catch {
                print("Failed to delete todo: \(error)")
            }
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
