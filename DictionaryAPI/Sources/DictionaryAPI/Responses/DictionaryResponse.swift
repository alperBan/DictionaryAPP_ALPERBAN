//
//  File.swift
//  
//
//  Created by Alper Ban on 31.05.2023.
//

import Foundation
public struct DictionaryResponse: Decodable {
    public let result: [JSON]
    public let results: [JSONS]
    
    private enum RootCodingKeys: String, CodingKey {
        case result
        case results
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        self.result = try container.decode([JSON].self, forKey: .result)
        self.results = try container.decode([JSONS].self, forKey: .results)
    }
}
