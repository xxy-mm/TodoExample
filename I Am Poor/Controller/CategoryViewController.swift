//
//  ViewController.swift
//  I Am Poor
//
//  Created by Darian Mitchell on 2024/7/25.
//

import RealmSwift
import UIKit

class CategoryViewController: UITableViewController {
    private let realm = try! Realm()
    private var categoryResults: Results<Category>?
    private var token: NotificationToken?
    private var selectedCategory: Category?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    func loadData() {
        categoryResults = realm.objects(Category.self)
    }

    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField?
        let alertControlelr = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        alertControlelr.addTextField { field in
            textField = field
        }
        let action = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let text = textField?.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            do {
                try self.realm.write {
                    let category = Category(name: text)
                    self.realm.add(category)
                }
            } catch {
                print("Failed to add new category: \(error.localizedDescription)")
            }
        }
        alertControlelr.addAction(action)
        present(alertControlelr, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        print("will appear")
        token = realm.observe { _, _ in
            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("will disappear")
        token?.invalidate()
    }
}

// MARK: - Table view data source

extension CategoryViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryResults?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let results = categoryResults {
            cell.textLabel?.text = results[indexPath.row].name
        }
        return cell
    }
}

// MARK: - Table view delegate

extension CategoryViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categoryResults?[indexPath.row]
        performSegue(withIdentifier: Constants.Segues.CATEGORY_TO_TODO, sender: self)
        DispatchQueue.main.async {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - Navigation

extension CategoryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.CATEGORY_TO_TODO,
           let selectedCategory,
           let todoVC = segue.destination as? TodoViewController {
            todoVC.category = selectedCategory
        }else {
            print("Selected category is not set.")
        }
    }
}
