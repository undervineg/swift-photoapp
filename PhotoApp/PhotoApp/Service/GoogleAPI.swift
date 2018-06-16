//
//  GoogleAPI.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 6. 15..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Foundation

enum GoogleAPI {
    case doodle
    case detailImage(Doodle)
}

extension GoogleAPI: API {
    var baseURL: URL {
        switch self {
        case .doodle:
            return URL(string: "http://125.209.194.123")!
        case .detailImage(let doodle):
            return URL(string: doodle.image)!
        }
    }

    var path: String? {
        switch self {
        case .doodle:
            return "/doodle.php"
        case .detailImage:
            return nil
        }
    }

    var httpMethod: HTTPMethod { return .get }
}
