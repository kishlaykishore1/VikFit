//
//  OtherUserModal.swift
//  VIKFIT
//

import Foundation
// MARK: - OtherUserModal
struct OtherUserModal: Codable {
    let id, firstName, lastName, phoneNumber: String
    let email, userType, bio, gender: String
    let plans, dob, bodyType, loginBy: String
    let height, weight, weightGoal: Int
    let isNotification: Bool
    let age: Int
    let profilePic: String
    let followers, followings: Int
    let verified, isFollow, isBlock: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case email
        case userType = "user_type"
        case bio, gender, plans, dob
        case bodyType = "body_type"
        case loginBy = "login_by"
        case height, weight
        case weightGoal = "weight_goal"
        case isNotification = "is_notification"
        case age
        case profilePic = "profile_pic"
        case followers, followings, verified
        case isFollow = "is_follow"
        case isBlock = "is_block"
    }
}
