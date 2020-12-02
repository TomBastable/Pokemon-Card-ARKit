//
//  ImageDownloader.swift
//  hUMBL
//
//  Created by Tom Bastable on 10/07/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Asyncronous Image Downloader
///made with URLSessions so that the UI doesn't freeze when fetching.
struct ImageDownloader {

    static let imageCache = NSCache<NSString, UIImage>()

    public func retrieveImage(urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {

        if let cachedImage = ImageDownloader.imageCache.object(forKey: NSString(string: urlString)) {
            completion(cachedImage, nil)
            print("cached image")
            return
        }

        guard let url = URL(string: urlString) else {

            completion(nil, PokeError.requestFailed)
            return
        }

        URLSession.shared.dataTask(with: url) { (data, _, error) in

            if error != nil {
                completion(nil, error)
                return
            }

            DispatchQueue.main.async {
                if let data = data {
                    if let image = UIImage(data: data) {
                        ImageDownloader.self.imageCache.setObject(image, forKey: NSString(string: urlString))
                        completion(image, nil)
                    }
                }
            }
        }.resume()

    }

}
