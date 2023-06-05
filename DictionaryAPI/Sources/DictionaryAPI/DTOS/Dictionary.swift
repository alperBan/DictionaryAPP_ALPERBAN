//
//  Dictionary.swift
//  
//
//  Created by Alper Ban on 31.05.2023.
//

import Foundation

public struct WordMeaningResult: Decodable {
    public let result: [JSON]?
    
    enum CodingKeys: String, CodingKey {
        case result
    }
    
    public init(result: [JSON]?) {
        self.result = result
    }
}

public struct JSON: Decodable {
    public let meanings: [Meanings]
    public let phonetics: [Phonetics]
    
    enum CodingKeys: String, CodingKey {
        case meanings
        case phonetics
    }
}

public struct Phonetics: Decodable {
    public let text: String?
    public let audio: String?
    
    enum CodingKeys: String, CodingKey {
        case text = "text"
        case audio = "audio"
    }
}

public struct Meanings: Decodable {
    public let partOfSpeech: String?
    public let definitions: [Definition]
    
    enum CodingKeys: String, CodingKey {
        case partOfSpeech = "partOfSpeech"
        case definitions
    }
}

public struct Definition: Decodable {
    public let definition: String?
    public let example: String?
    
    enum CodingKeys: String, CodingKey {
        case definition = "definition"
        case example = "example"
    }
}

public struct WordSynonymsResult: Decodable {
    public let results: [JSONS]?
    
    enum CodingKeys: String, CodingKey {
        case results
    }
}

public struct JSONS: Decodable {
    public let word: String?
    
    enum CodingKeys: String, CodingKey {
        case word = "word"
    }
}
