//
//  Doodles.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 5. 21..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Foundation

struct Doodles: Decodable {
    let title: String
    let image: String
    let date: String
    let imageData: Thumbnail?
}
