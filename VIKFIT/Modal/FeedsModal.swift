//
//  FeedsModal.swift
//  VIKFIT
//

import Foundation

// MARK: - FeedsModal
struct FeedsModal: Codable {
    let id: String
    let profilePic: String
    let userID, firstName, lastName: String
    let verified: Bool
    let feedMessage: String
    let image: [String]
    var comments, likes: Int
    var userComment, userLike: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case profilePic = "profile_pic"
        case userID = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case verified
        case feedMessage = "description"
        case image, comments, likes
        case userComment = "user_comment"
        case userLike = "user_like"
        case createdAt = "created_at"
    }
}
