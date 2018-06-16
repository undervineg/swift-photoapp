//
//  Networking.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 6. 15..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Foundation

class Networking<Target: API> {

    typealias NetworkingCompletion = (Data) -> Void

    func request(_ target: Target, _ handler: @escaping NetworkingCompletion) {
        var url = target.baseURL
        if let path = target.path {
            url.appendPathComponent(path)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = target.httpMethod.rawValue
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("network error: ", error)
            }
            if let data = data {
                handler(data)
            } else {
                print("data nil error")
            }
        }.resume()
    }

}
