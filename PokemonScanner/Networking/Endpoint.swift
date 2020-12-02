//
//  Endpoint.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 30/11/2020.
//

import Foundation

protocol Endpoint {
    
    var base: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    
}

extension Endpoint {
    
    var urlComponents: URLComponents {
        
        var components = URLComponents(string: base)!
        components.path = path
        components.queryItems = queryItems
        
        return components
    }
    
    var request: URLRequest {
        
        let url = urlComponents.url!
        return URLRequest(url: url)
        
    }
    
}

enum PokemonTCGEndpoints {
    
    case baseCardByName(name: String)
}

extension PokemonTCGEndpoints: Endpoint {
    
    var base: String {
        return "https://api.pokemontcg.io"
    }
    
    var path: String {
        
        switch self {
            
        case .baseCardByName : return "/v1/cards"
            
        }
        
    }
    
    var queryItems: [URLQueryItem] {
        
    switch self {
        
    case .baseCardByName(let name):
        
        var result = [URLQueryItem]()
        let feedType: URLQueryItem = URLQueryItem(name: "setCode", value: "base1")
        result.append(feedType)
        let version: URLQueryItem = URLQueryItem(name: "name", value: name)
        result.append(version)
        
        return result
        
        }
    }
}
