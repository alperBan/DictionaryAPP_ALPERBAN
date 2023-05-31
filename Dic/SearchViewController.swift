//
//  ViewController.swift
//  Dic
//
//  Created by Alper Ban on 28.05.2023.
//
import CoreData
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class SearchViewController: UIViewController, LoadingShowable {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchTable: UITableView!
    
    var searchList = [RecentSearch]()
        let context = appDelegate.persistentContainer.viewContext
        
        override func viewDidLoad() {
            super.viewDidLoad()
            textField.layer.cornerRadius = 10
            searchTable.dataSource = self
            searchTable.delegate = self
            searchTable.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchTableViewCell")
            setupTextField()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            textField.text = ""
            
            let fetchRequest: NSFetchRequest<RecentSearch> = RecentSearch.fetchRequest()
            
            do {
                searchList = try context.fetch(fetchRequest)
                searchList = searchList.reversed()
                searchTable.reloadData()
            } catch {
                print("Son aramalar getirilemedi: \(error)")
            }
        }
        
        private func setupTextField() {
            let imageView = UIImageView(image: UIImage(named: "search"))
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 20, y: 0, width: 20, height: 20)
            
            let placeholderText = NSAttributedString(string: "Ara", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            textField.leftView = imageView
            textField.leftViewMode = .always
            textField.attributedPlaceholder = placeholderText
            textField.layer.cornerRadius = 10
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let navigationController = segue.destination
            navigationController.modalPresentationStyle = .fullScreen
        }
        
        @IBAction func searchButton(_ sender: Any) {
            let word = textField.text ?? ""
            
            if word.isEmpty {
                let alert = UIAlertController(title: "Uyarı", message: "Bir kelime girin!", preferredStyle: .alert)
                let cancelButton = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
                alert.addAction(cancelButton)
                self.present(alert, animated: true, completion: nil)
            } else {
                let recentSearch = RecentSearch(context: context)
                recentSearch.searchList = word
                
                appDelegate.saveContext()
                
                searchList.insert(recentSearch, at: 0)
                if searchList.count > 5 {
                    let lastSearch = searchList.removeLast()
                    context.delete(lastSearch)
                    appDelegate.saveContext()
                }
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! DetailViewController
                vc.word = word
                self.show(vc, sender: nil)
            }
            print(searchList)
        }
    }

    extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchList.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell", for: indexPath) as! SearchTableViewCell
            cell.recentSearchLabel.text = searchList[indexPath.row].searchList
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedWord = searchList[indexPath.row].searchList
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! DetailViewController
            vc.word = selectedWord!
            self.show(vc, sender: nil)
        }
    }



