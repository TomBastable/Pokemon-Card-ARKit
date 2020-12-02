//
//  JSONDownloader.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 30/11/2020.
//

import Foundation

import Foundation

class JSONDownloader {
    let session: URLSession
    let decoder = JSONDecoder()
    static let shared = JSONDownloader()

    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    typealias JSON = Data?
    typealias JSONTaskCompletionHandler = (JSON?, Error?) -> Void
    
    func jsonTask(with request: URLRequest, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, PokeError.invalidData)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                        
                        completion(data, nil)
                        
                } else {
                    completion(nil, PokeError.coordinateError)
                }
            } else {
                completion(nil, PokeError.jsonConversionFailure)
            }
            
        }
        
        return task
    }
}
