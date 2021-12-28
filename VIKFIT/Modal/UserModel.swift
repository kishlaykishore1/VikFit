//
//  UserModel.swift
//  Open Drivers
//


import Foundation

// MARK: - UserModel
struct UserModel: Codable {
    let id, firstName, lastName, phoneNumber: String
    let email, userType, bio, gender: String
    let plans, dob, bodyType, loginBy: String
    let height, weight, weightGoal: Int
    let isNotification: Bool
    let age: Int
    let profilePic: String
    let followers, followings: Int
    let verified: Bool

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
    }
    
    static func storeUserModel(value: [String: Any]) {
        
        Constants.kUserDefaults.set(value, forKey: "User")
        
    }
    
    static func getUserModel() -> UserModel? {
        
        if let getDate = Constants.kUserDefaults.value(forKey: "User") as? [String: Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: getDate, options: .prettyPrinted)
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(UserModel.self, from: jsonData)
                    
                } catch let err {
                    print("Err", err)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
}
