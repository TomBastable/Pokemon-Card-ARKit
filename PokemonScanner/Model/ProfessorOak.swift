//
//  ProfessorOak.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 01/12/2020.
//

import Foundation
import Vision
import UIKit

protocol ProfessorOakDelegate: AnyObject {
    func pokemonRecognised(_ name: String)
}


// MARK: - Professor Oak
/**
Professor Oak is primarily designed to answer the age old question: Who's that pokemon?
Used Vision (OCR) to recognise the pokemon. Use that recognition to call
The TCG API.

 - Author:
 Tom Bastable
 - Important:
 Has not gone through QA
 - Version: 0.01a
 
 Stored Properties:
 - shared: Holds an initialised static property of ProfessorOak.
 - delegate: holds the ProfessorOakDelegate
 - pokedex: has an initialised property of Pokedex.
 */
class ProfessorOak {

    ///Static store of Professor Oak
    static let shared = ProfessorOak()
    ///The delegate method of ProfessorOak
    weak var delegate: ProfessorOakDelegate?
    ///Holds 152 pokemon from the original set.
    let pokedex = Pokedex()

    // MARK: - Who's That Pokemon?
    ///Take in an image, and request an OCR Session from Vision to recognise the pokemon.
    func whosThatPokemon(_ image: UIImage) {
        // Get the CGImage on which to perform requests.
        guard let cgImage = image.cgImage else { return }
        //setup the request
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        //submit the request
        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }

    // MARK: - Recognise Text Handler
    ///Handles the Vision request result.
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        //unwrap the observations from the request
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        //compact map the observations.
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        //these come back in text blocks. Go through them
        //to see if one matches a pokemon within the pokedex.
        for string in recognizedStrings {
            if pokedex.basePokemon.contains(string) {
                delegate?.pokemonRecognised(string)
            }
        }
    }
}
