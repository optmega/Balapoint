//
//  User.swift
//  Metis
//
//  Created by David S on 11/15/17.
//  Copyright © 2017 David S. All rights reserved.
//

import Foundation

class Userr {
    
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
    var postTitle: String?
    var bio: String?
    var website: String?
    var isBlocking: Bool?
}

extension Userr {
    static func transformUser(dict: [String: Any], key: String) -> Userr {
        let user = Userr()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.id = key
        user.postTitle = dict["title"] as? String
        user.bio = dict["bio"] as? String
        user.website = dict["website"] as? String
        return user
    }
}
