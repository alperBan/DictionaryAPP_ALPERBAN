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
        textField.delegate = self
        textField.addTarget(self, action: #selector(dismissKeyboard), for: .editingDidEndOnExit)
        textField.inputAccessoryView = createKeyboardToolbar()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func createKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let searchButton = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchButtonTapped))
        flexibleSpace.width = toolbar.frame.width / 3
        toolbar.items = [flexibleSpace, searchButton, flexibleSpace]
        toolbar.barTintColor = .link
        searchButton.tintColor = .white
        return toolbar
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        textField.inputAccessoryView?.isHidden = false
    }

    @objc func keyboardWillHide(notification: Notification) {
        textField.inputAccessoryView?.isHidden = true
    }
    
    @objc func searchButtonTapped() {
        textField.resignFirstResponder()
        searchButton(self)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = ""
        
        let fetchRequest: NSFetchRequest<RecentSearch> = RecentSearch.fetchRequest()
        
        do {
            searchList = try context.fetch(fetchRequest).reversed()
            searchTable.reloadData()
        } catch {
            print("Son aramalar getirilemedi: \(error)")
        }
    }
    
    private func setupTextField() {
        let imageView = UIImageView(image: UIImage(named: "search"))
        imageView.contentMode = .scaleToFill
        
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        paddingView.addSubview(imageView)
        imageView.center = paddingView.center
        
        let placeholderText = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.attributedPlaceholder = placeholderText
        textField.layer.cornerRadius = 10
        textField.returnKeyType = .search
        textField.autocorrectionType = .no
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination
        navigationController.modalPresentationStyle = .fullScreen
    }
    
    
    
    @IBAction func searchButton(_ sender: Any) {
        let word = textField.text ?? ""
        
        if word.isEmpty {
            let alert = UIAlertController(title: "Heeeey:D", message: "Enter a Word!", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        } else {
            if let existingIndex = searchList.firstIndex(where: { $0.searchList == word }) {
                let existingSearch = searchList.remove(at: existingIndex)
                context.delete(existingSearch)
            }
            
            let recentSearch = RecentSearch(context: context)
            recentSearch.searchList = word
            searchList.insert(recentSearch, at: 0)
            
            if searchList.count > 5 {
                let lastSearch = searchList.removeLast()
                context.delete(lastSearch)
            }
            
            appDelegate.saveContext()
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! DetailViewController
            vc.word = word
            self.show(vc, sender: nil)
        }
        print(searchList)
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchButton(self)
        return true
    }
}
