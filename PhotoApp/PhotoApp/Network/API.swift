//
//  API.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 6. 15..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Foundation

protocol API {
    var baseURL: URL { get }
    var path: String? { get }
    var httpMethod: HTTPMethod { get }
}

enum HTTPMethod: String {
    case get = "GET"
}
