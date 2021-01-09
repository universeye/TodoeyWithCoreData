//
//  ViewController.swift
//  TodoeyWithCoreData
//
//  Created by Terry Kuo on 2021/1/7.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {

    
    var itemArray = [Item]()
    
    
    var selectedCategory : Category? {
        didSet {
            loadItems(predicate: categoryPredicate)
        }
    }
    
    lazy var categoryPredicate = NSPredicate(format: "parrentCategory.name MATCHES %@", selectedCategory!.name!)
    
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //searchBar.delegate = self
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //loadItems()
    }
    
    //MARK: - Tableview Data Source Methods

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = itemArray[indexPath.row] //用太多次 所以存在一個變數裡用
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListTableViewCell", for: indexPath)
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
    
    //MARK: - Tableview Delegate Method

    
    //tells the delegate, which is current class, that the specified row is now selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //mind that these two line's order MATTER
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
       
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.endEditing(true)
    }

//MARK: - Add New Items

    @IBAction func addButtomPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            

            //tapping into UIApplication class -> shared Singleton object
            //casting into our app: AppDelegate
            let newItem = Item(context: self.context) //coreData class
            
            newItem.title = textField.text!
            newItem.done = false
            newItem.parrentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        
        }
        
        
        alert.addTextField { (UITextField) in
            UITextField.placeholder = "create new item"
            textField = UITextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Model Manupulation Methods
    
    func saveItems() {
        do {
            //let data = try encoder.encode(itemArray)
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
            try context.save()
        } catch {
            print("Error saving context with \(error)")
        }
        self.tableView.reloadData()
    }

    
    func loadItems (with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate) { //external parameters: "with" is for outside calling, Internal parameter: "request" is for this function

        //let request: NSFetchRequest<Item> = Item.fetchRequest()
        //NSFetchRequest need to specify the result type
        
        
        //let predicate = NSPredicate(format: "parrentCategory.name MATCHES %@", selectedCategory!.name!)
        
        request.predicate = predicate
        
        
        
        
        do {
            itemArray = try context.fetch(request) //this FETCH method has an output NSFetchRequestResult, which we known is an array of items
        } catch {
            print("Error fetching data from context, error: \(error)")
        }
        
        tableView.reloadData()
    }
    
}


//MARK: - SearchBar Delegate method


extension TableViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        searchBar.endEditing(true)
        
        
        //        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) //searchbar.text is going to pass in %@
        //        //print(searchBar.text!)
        //        request.predicate = predicate
        //
        
        
        let sortDescriptr = NSSortDescriptor(key: "title", ascending: true)
        
        request.sortDescriptors = [sortDescriptr]
        loadItems(with: request, predicate: NSCompoundPredicate(type:.and, subpredicates:[
            categoryPredicate,
            NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            ]))
        
        //        do {
        //            itemArray = try context.fetch(request) //this FETCH method has an output NSFetchRequestResult, which we known is an array of items
        //        } catch {
        //            print("Error fetching data from context, error: \(error)")
        //        }
        //tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { //ways to go back to original list
            loadItems(predicate: categoryPredicate)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()  
            }
        }
    }
    
}



