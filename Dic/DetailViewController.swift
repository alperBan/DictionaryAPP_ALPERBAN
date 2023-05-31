//
//  SecondViewController.swift
//  Dic
//
//  Created by Alper Ban on 28.05.2023.
//
import AVFoundation
import UIKit
import DictionaryAPI

class DetailViewController: UIViewController,LoadingShowable {
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var phoneticLabel: UILabel!
    @IBOutlet weak var nounButton: UIButton!
    @IBOutlet weak var verbButton: UIButton!
    @IBOutlet weak var adjectiveButton: UIButton!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var adverButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    var word = String()
    var meanings: [Meanings] = []
    var filteredMeanings: [Meanings] = []
    let service: DictionaryServiceProtocol = DictionaryService()
    var audioPlayer: AVAudioPlayer?
    var currentAudioURLIndex = 0
    var synonymsArray: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButtonImage = UIImage(named: "left-arrow")
        navigationController?.navigationBar.backIndicatorImage = backButtonImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        removeButton.isHidden = true
        wordLabel.text = word.uppercased()
        service.fetchDictionary(word: word) { [weak self] response in
            switch response {
            case .success(let data):
                guard let self = self else {
                    return
                }
                
                guard let phonetics = data.0.first?.phonetics else {
                    return
                }
                
                if let firstPhonetic = phonetics.first {
                    self.phoneticLabel.text = firstPhonetic.text
                }
                
                self.meanings = data.0.first?.meanings ?? []
                self.filteredMeanings = self.meanings
                self.listTableView.reloadData()
                
                let audioURLStrings = data.0.flatMap { $0.phonetics.compactMap { $0.audio } }
                if !audioURLStrings.isEmpty {
                    self.fetchAudioData(audioURLStrings: audioURLStrings)
                } else {
                    self.audioButton.isEnabled = false
                }
                
                self.synonymsArray = data.1.compactMap { $0.word }
                print("Synonyms Array: \(self.synonymsArray.prefix(5))")
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListTableViewCell")
        listTableView.register(UINib(nibName: "FooterTableViewCell", bundle: nil), forCellReuseIdentifier: "FooterTableViewCell")
    }
    
    func fetchAudioData(audioURLStrings: [String]) {
        guard currentAudioURLIndex < audioURLStrings.count else {
            return
        }
        
        let audioURLString = audioURLStrings[currentAudioURLIndex]
        guard let audioURL = URL(string: audioURLString) else {
            // Geçerli bir URL değil
            currentAudioURLIndex += 1
            fetchAudioData(audioURLStrings: audioURLStrings)
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            do {
                let audioData = try Data(contentsOf: audioURL)
                
                if audioData.isEmpty {
                    // Eğer gelen audio verisi boş ise, bir sonraki URL'den veri almak için fonksiyonu tekrar çağırıyoruz
                    self?.currentAudioURLIndex += 1
                    self?.fetchAudioData(audioURLStrings: audioURLStrings)
                } else {
                    DispatchQueue.main.async {
                        self?.initializeAudioPlayer(with: audioData)
                    }
                }
            } catch {
                print("Error loading audio data: \(error)")
            }
        }
    }
    
    func initializeAudioPlayer(with audioData: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioButton.isEnabled = true // Ses verileri mevcut olduğunda ses düğmesini etkinleştir
        } catch {
            print("Error initializing audio player: \(error)")
            audioButton.isEnabled = false
        }
    }
    
    
    @IBAction func nounButtonTapped(_ sender: UIButton) {
        updateButtonAppearance(sender)
        filteredMeanings = meanings.filter { $0.partOfSpeech == "noun" }
        listTableView.reloadData()
        listTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        
        removeButton.isHidden = false
    }
    
    @IBAction func verbButtonTapped(_ sender: UIButton) {
        updateButtonAppearance(sender)
        filteredMeanings = meanings.filter { $0.partOfSpeech == "verb" }
        listTableView.reloadData()
        listTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        
        removeButton.isHidden = false
    }
    
    @IBAction func adjectiveButtonTapped(_ sender: UIButton) {
        updateButtonAppearance(sender)
        filteredMeanings = meanings.filter { $0.partOfSpeech == "adjective" }
        listTableView.reloadData()
        listTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
                removeButton.isHidden = false
    }
    
    @IBAction func adverbButtonTapped(_ sender: UIButton) {
        updateButtonAppearance(sender)
        filteredMeanings = meanings.filter { $0.partOfSpeech == "adverb" }
        listTableView.reloadData()
        listTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        // Show the removeButton
        removeButton.isHidden = false
    }
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        updateButtonAppearance(sender)
        // Reset the filteredMeanings to show all meanings and reload the table view
        filteredMeanings = meanings
        listTableView.reloadData()
        listTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        // Hide the removeButton again
        removeButton.isHidden = true
    }
    private func updateButtonAppearance(_ button: UIButton) {
        // Tüm butonların kenarlık rengini normale döndür
        nounButton.layer.borderColor = UIColor.clear.cgColor
        verbButton.layer.borderColor = UIColor.clear.cgColor
        adjectiveButton.layer.borderColor = UIColor.clear.cgColor
        adverButton.layer.borderColor = UIColor.clear.cgColor
        
        // Tıklanan butonun kenarlık rengini güncelle
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 8.0
    }
    
    @IBAction func audioButtonTapped(_ sender: UIButton) {
        audioPlayer?.play()
    }
    
 
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
    }
}
    extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let totalDefinitionsCount = filteredMeanings.reduce(0) { $0 + $1.definitions.count }
            return totalDefinitionsCount + 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let totalDefinitionsCount = filteredMeanings.reduce(0) { $0 + $1.definitions.count }
            
            if indexPath.row == totalDefinitionsCount {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FooterTableViewCell", for: indexPath) as! FooterTableViewCell
                
                if synonymsArray.isEmpty {
                    cell.isHidden = true
                } else {
                    let maxSynonymsCount = min(synonymsArray.count, 5) // En fazla 5 elemanı yazdıralım
                    
                    for i in 0..<maxSynonymsCount {
                        let synonym = synonymsArray[i]
                        
                        switch i {
                        case 0:
                            cell.wordLabel.text = synonym
                            cell.wordLabel.isHidden = false
                        case 1:
                            cell.wordLabel2.text = synonym
                            cell.wordLabel2.isHidden = false
                        case 2:
                            cell.wordLabel3.text = synonym
                            cell.wordLabel3.isHidden = false
                        case 3:
                            cell.wordLabel4.text = synonym
                            cell.wordLabel4.isHidden = false
                        case 4:
                            cell.wordLabel5.text = synonym
                            cell.wordLabel5.isHidden = false
                        default:
                            break
                        }
                    }
                    
                    // Hide labels that are not used
                    for i in maxSynonymsCount..<5 {
                        switch i {
                        case 0:
                            cell.wordLabel.isHidden = true
                        case 1:
                            cell.wordLabel2.isHidden = true
                        case 2:
                            cell.wordLabel3.isHidden = true
                        case 3:
                            cell.wordLabel4.isHidden = true
                        case 4:
                            cell.wordLabel5.isHidden = true
                        default:
                            break
                        }
                    }
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
                
                let totalDefinitionsCount = filteredMeanings.reduce(0) { $0 + $1.definitions.count }
                
                var currentDefinitionIndex = 0
                var currentMeaningIndex = 0
                
                while currentMeaningIndex < filteredMeanings.count {
                    let meaning = filteredMeanings[currentMeaningIndex]
                    let definitionsCount = meaning.definitions.count
                    
                    if currentDefinitionIndex + definitionsCount > indexPath.row {
                        let definitionIndex = indexPath.row - currentDefinitionIndex
                        if definitionIndex < definitionsCount {
                            let definition = meaning.definitions[definitionIndex]
                            
                            cell.numberLabel.text = "\(indexPath.row + 1)-"
                            cell.partOfSpeechLabel.text = meaning.partOfSpeech
                            cell.definitionsLabel.text = definition.definition
                            
                            if let exampleText = definition.example {
                                cell.titleLabel.text = "Example"
                                cell.exampleLabel.text = exampleText
                                cell.titleLabel.isHidden = false
                            } else {
                                cell.titleLabel.isHidden = true
                                cell.exampleLabel.text = ""
                            }
                            
                            return cell
                        }
                    }
                    
                    currentDefinitionIndex += definitionsCount
                    currentMeaningIndex += 1
                }
                
                return UITableViewCell()
            }
        }
    }


