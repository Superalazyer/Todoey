//
//  ViewController.swift
//  Todoey
//
//  Created by ALazyer on 2018/9/27.
//  Copyright © 2018 ALazyer. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]() //create a Item object, item the newly built class
    
    var selectedCategory : Category?{
        didSet{
            loadItems() // everything that happens as soon as selectedCategory gets set with a value, this is a perfect place to call loadItems()
        }
    } //this could be nil until we can set it in CategoryViewController.swift

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        /* because these codes have previously executed, so we don't need to do it again
        let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Buy Eggos"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Destroy Demogorgon"
        itemArray.append(newItem3)
        */
                
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) //cell can be reused, for example, the first cell can be checked, but since this cell is also reused, this means if the table has a lot of cells, this first cell will also be used in another cell, another cell will also be checked. So, the checkmark should not be associated with cell, instead, it should be associated with the data
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none //ternary operator, exactly the same meaning as the below
        
        /*
        if item.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        */
        
        return cell
        
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
//        context.delete(itemArray[indexPath.row]) //pay specific attention to the order of these two lines
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done //exactly the same as the if-else statement below
        
        saveItems()
        
        /*
        if itemArray[indexPath.row].done == false {
            itemArray[indexPath.row].done = true
        } else {
            itemArray[indexPath.row].done = false
        }
        */
        
        tableView.deselectRow(at: indexPath, animated: true) //when selecting a cell, the cell will be grey, this code cancel the grey effect
    }
    
     //MARK - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()//define this variable so that it can be used by all the functions inside this function
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the add item button on our UIAlert
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        
        self.tableView.reloadData() //the data has already been appended, but only after being reloaded can it show up
        
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) { //this means return an array of Items, "with" is external parameter which is going to be used outside this function, "request" is internal parameter which is going to be used inside this function. When calling this function, if we provide a NSFetchRequest paramter, then it will use this paramter, if we don't provide a paramter, then it will simply use the default value. this default value is used by calling this function within viewDidLoad()

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate]) //why we need to use this? view video at "adding the delegate method"
//
//        request.predicate = compoundPredicate
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
}


//MARK: - Search bar methods

//use extension to define different delegates and the functions of these delegates, instead of writting them inside the TodoListViewController, this is more clear
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) //this is querry statement, c means case sensative, and d means diacritic sensitive
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate) //use external paramter
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { //when texts in search bar changed and the number of texts became 0, the load the default items
            loadItems()
            
            DispatchQueue.main.async { //this dispatchQueue object manages work items - the threads
                searchBar.resignFirstResponder() // this just means that the searchBar should no longer be the thing that is currently selected, the keyboard should go away, the cursor in the searchBar should be no longer flash
            }
            
        }
    }
    
}

