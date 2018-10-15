//
//  CategoryViewController.swift
//  Todoey
//
//  Created by ALazyer on 2018/10/10.
//  Copyright © 2018 ALazyer. All rights reserved.
//

import UIKit
import CoreData

//written by self except for the delegate method
class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
    }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell
        
    }
    
    //MARK: - Data Manupulation Methods
    
    func saveCategory() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        self.tableView.reloadData() //the data has already been appended, but only after being reloaded can it show up
        
    }
    
    func loadCategory(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Catogery", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen once the user clicks the add item button on our UIAlert
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let newCategory = Category(context: self.context)
            
            newCategory.name = textField.text!
            
            self.categoryArray.append(newCategory)
            
            self.saveCategory()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - TableView Delegate Methods
    
    //clicking a category goes to the list of items that are related to this category, which means we need a segue here, and a delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController //a reference to the destination of the view controller
        
        if let indexPath = tableView.indexPathForSelectedRow { // the tableView.indexPathForSelectedRow could be nil,meaning there's no cell selected currently
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
}
