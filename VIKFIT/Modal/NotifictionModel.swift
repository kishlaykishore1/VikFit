//
//  NotifictionModel.swift
//  VIKFIT
//

import Foundation

// MARK: - NotificationListModelElement
struct NotificationListModel: Codable {
    let id, title, message, type: String
    let link: String
    let userID, postID: String
    let imageLink: String
    let seen: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, message, type, link
        case userID = "user_id"
        case postID = "post_id"
        case imageLink = "image_link"
        case seen
        case createdAt = "created_at"
    }
}
