//
//  File.swift
//  
//
//  Created by Alper Ban on 31.05.2023.
//

import Foundation
import Alamofire

public protocol DictionaryServiceProtocol: AnyObject {
    func fetchDictionary(word: String, completion: @escaping (Result<([JSON], [JSONS]), Error>) -> Void)
}

public class DictionaryService: DictionaryServiceProtocol {
    public init() {}
    
    public func fetchDictionary(word: String, completion: @escaping (Result<([JSON], [JSONS]), Error>) -> Void) {
        let dictionaryAPIURLString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)"
        let datamuseAPIURLString = "https://api.datamuse.com/words?rel_syn=\(word)"
        
        var responseResult: [JSON] = []
        var synonymsResult: [JSONS] = []
        
        let group = DispatchGroup()
        
        group.enter()
        AF.request(dictionaryAPIURLString).responseData { response in
            defer { group.leave() }
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                
                do {
                    let response = try decoder.decode([JSON].self, from: data)
                    responseResult = response
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                print("******** Geçici Bir hata Oluştu \(error.localizedDescription)***********")
                completion(.failure(error))
            }
        }
        
        group.enter()
        AF.request(datamuseAPIURLString).responseData { response in
            defer { group.leave() }
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode([JSONS].self, from: data)
                    synonymsResult = response
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                print("******** Geçici Bir hata Oluştu \(error.localizedDescription)***********")
                completion(.failure(error))
            }
        }
        
        group.notify(queue: .main) {
            completion(.success((responseResult, synonymsResult)))
        }
    }
}

