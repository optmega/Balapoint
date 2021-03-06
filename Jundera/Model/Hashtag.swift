//
//  Hashtag.swift
//  Balapoint
//
//  Created by David S on 11/6/18.
//  Copyright © 2018 David S. All rights reserved.
//  May not need this afterall

import Foundation
import Firebase

class Hashtag {
    var hashtag: String?
}

extension Hashtag {
    
    static func transformHashtag(dict: [String: Any], key: String) -> Hashtag {
        let tag = Hashtag()
        tag.hashtag = dict["hashtag"] as? String
        return tag
    }
}
