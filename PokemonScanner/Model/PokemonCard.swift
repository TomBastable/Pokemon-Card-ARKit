//
//  PokemonCard.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 30/11/2020.
//

import Foundation

struct PokemonCard: Codable {
    let name: String
    let imageUrl: String
    let hp: String
    let artist: String
    let types: [String]
    let rarity: String
}
