//
//  Post.swift
//  Metis
//
//  Created by David S on 11/15/17.
//  Copyright © 2017 David S. All rights reserved.
//  Likes are just the posts we want to save. Will have to refactor later. 

import Foundation
import FirebaseAuth

class Post {
    
    var caption: String?
    var photoUrl: String?
    var uid: String?
    var id: String?
    var likeCount: Int? //may not need
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var ratio: CGFloat?
    var title: String?
    var body: String?
    var saved: Dictionary<String, Any>?
    var isSaved: Bool?
    var date: Date?
    var hashtag: String?

}

extension Post {
    
    static func transformPostPhoto(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.ratio = dict["ratio"] as? CGFloat
        post.title = dict["title"] as? String
        post.body = dict["body"] as? String
        post.saved = dict["saved"] as? Dictionary<String, Any>
        post.hashtag = dict["hashtag"] as? String //testing
      
        
        let secondsAgoFrom1970 = dict["time_interval"] as? Double ?? 0
        post.date = Date(timeIntervalSince1970: (secondsAgoFrom1970 / 1_000.0))
 
        if let currentUserId = Auth.auth().currentUser?.uid {
            if post.saved != nil {
                post.isSaved = post.saved![currentUserId] != nil
            }
        }
      
        return post
    }
}


