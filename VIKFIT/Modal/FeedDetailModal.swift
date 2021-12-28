//
//  FeedDetailModal.swift
//  VIKFIT
//

import Foundation

// MARK: - FeedDetailModal
struct FeedDetailModal: Codable {
    let id, userID: String
    let profilePic: String
    let verified: Bool
    let firstName, lastName, feedMessage, image: String
    let createdAt: String
    var userComment, userLike: Bool
    var comments: [Comment]
    let commentTotal, likeTotal: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case profilePic = "profile_pic"
        case verified
        case firstName = "first_name"
        case lastName = "last_name"
        case feedMessage = "description"
        case image
        case createdAt = "created_at"
        case userComment = "user_comment"
        case userLike = "user_like"
        case commentTotal, likeTotal, comments
    }
}

// MARK: - Comment
struct Comment: Codable {
       let id, comment, image, userID: String
    let firstName, lastName: String
    let verified: Bool
    let profilePic: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, comment, image
        case userID = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case verified
        case profilePic = "profile_pic"
        case createdAt = "created_at"
    }
}
