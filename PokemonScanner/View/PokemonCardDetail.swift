//
//  PokemonCardDetail.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 30/11/2020.
//

import Foundation
import UIKit

// MARK: - Pokemon Card Detail View
/**
Displays any given pokemon cards data. This will only ever be displayed
Inside an ARSCNView as an image. Mainly used as setup.

 - Author:
 Tom Bastable
 - Important:
 Has not gone through QA
 - Version: 0.01a

 Whats new in this version:
 - View now downloads the Pokemon Card Image, and then adds the UI.
 */
class PokemonCardDetailView: UIView {

    //IBOutlets
    @IBOutlet var pokemonNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var rarityNameLabel: UILabel!
    @IBOutlet var hpLabel: UILabel!
    @IBOutlet var pokemonCardImageView: UIImageView!
    @IBOutlet var pokemonTypeImageView: UIImageView!

    // MARK: - Setup Pokemon Card
    ///This function setups up the Pokemon Card Detail View by taking in a PokemonCard.
    ///Completion handler will return an option error - if it's nil then setup is complete.
    func setupPokemonCard(card: PokemonCard, completion: @escaping (Error?) -> Void) {

        //Download the image
        ImageDownloader().retrieveImage(urlString: card.imageUrl) { (image, error) in
            //check for errors
            if error == nil {
                //process on main thread
                DispatchQueue.main.async {
                    //set all the data
                    self.pokemonNameLabel.text = card.name
                    self.artistNameLabel.text = card.artist
                    self.rarityNameLabel.text = card.rarity
                    self.hpLabel.text = "HP \(card.hp)"
                    self.pokemonTypeImageView.image = UIImage(named: "\(card.types[0]).png")
                    self.pokemonCardImageView.image = image
                }
                //complete
                completion(nil)

            } else if let error = error {
                //complete with error
                completion(error)
            }
        }
    }
}
