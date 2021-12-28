//
//  FollowersModel.swift
//  VIKFIT
//

import Foundation

// MARK: - FollowersModel
struct FollowersModel: Codable {
    let id: Int
    let firstName, lastName, profilePic: String

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePic = "profile_pic"
    }
}
