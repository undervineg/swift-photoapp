//
//  GoogleService.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 6. 15..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

class Cache {
    static let shared = Cache()
    let imageCache = NSCache<NSString, UIImage>()
}

class GoogleService {

    static let shared = GoogleService(networking: Networking<GoogleAPI>())

    private let networking: Networking<GoogleAPI>
    private let decoder = JSONDecoder()

    init(networking: Networking<GoogleAPI>) {
        self.networking = networking
    }

    func fetchDoodles(_ completion: @escaping ([Doodle]) -> ()) {
        networking.request(.doodle) { (data) in
            do {
                let doodles = try self.decoder.decode([Doodle].self, from: data)
                completion(doodles)
            } catch {
                print("decode error")
            }
        }
    }

    func fetchImage(from doodle: Doodle, _ completion: @escaping (UIImage?) -> ()) {

        if let cachedImage = Cache.shared.imageCache.object(forKey: doodle.image as NSString) {
            completion(cachedImage)
            return
        }

        networking.request(.detailImage(doodle)) { (data) in
            guard let loadedImage = UIImage(data: data) else { return }
            Cache.shared.imageCache.setObject(loadedImage, forKey: doodle.image as NSString)
            completion(loadedImage)
        }
    }
}
