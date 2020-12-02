//
//  PokeError.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 30/11/2020.
//

import Foundation

enum PokeError: LocalizedError {
    
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case requestFailed
    case jsonParsingFailure
    case coordinateError
    case mailSetupError
}

extension PokeError {
    public var errorDescription: String? {
        
        switch self {
        case .coordinateError:
            return NSLocalizedString("Error setting up coodinates.", comment: "Houston, We have a problem.")
        case .jsonConversionFailure:
            return NSLocalizedString("JSON Conversion Error.", comment: "Houston, We have a problem.")
        case .invalidData:
            return NSLocalizedString("Image Data Invalid.", comment: "Houston, We have a problem.")
        case .responseUnsuccessful:
            return NSLocalizedString("Response from the server was unsuccessful.", comment:"Houston, We have a problem.")
        case .jsonParsingFailure:
            return NSLocalizedString("JSON Parsing Error.", comment: "Houston, We have a problem.")
        case .requestFailed:
            return NSLocalizedString("API Request Failed. Most likely due to Internet Connection issues.", comment: "Houston, We have a problem.")
        case .mailSetupError:
            return NSLocalizedString("This Device is not setup to send email. Please rectify this and try again", comment: "Houston, We have a problem.")
    }
}
}
