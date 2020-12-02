//
//  PokemonTCGAPI.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 30/11/2020.
//

import Foundation

class PokemonTCGAPI {

    typealias Results = [String: Any]
    let decoder = JSONDecoder()
    static let shared = PokemonTCGAPI()

    func retrieveBasePokemonCard(name: String,
                                 completion: @escaping ([PokemonCard]?, Error?) -> Void){

        let endpoint = PokemonTCGEndpoints.baseCardByName(name: name)

        performRequest(with: endpoint) { results, error in

            guard let data = results else { completion(nil, error) ; return }

            do{
                let peoplesArray = try self.decoder.decode([String: [PokemonCard]].self, from: data)

                if let array = peoplesArray["cards"] {
                    completion(array, nil)
                }

            } catch { completion(nil, error) }
        }
    }

    private func performRequest(with endpoint: Endpoint,
                                completion: @escaping (Data?, Error?) -> Void) {

        let task = JSONDownloader.shared.jsonTask(with: endpoint.request) { json, error in

                guard let json = json else {
                    completion(nil, error)
                    return
                }
                completion(json, nil)
        }
        task.resume()
    }
}
