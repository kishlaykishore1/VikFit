//
//  ExerciesModel.swift
//  VIKFIT
//

import Foundation

// MARK: - ExerciseModel
struct ExerciseModel: Codable {
    let id, exercise, title: String
    let videoLink: String
    let thumbURL: String
    let datePublication: String
    var favoriteStatus: Bool

    enum CodingKeys: String, CodingKey {
        case id, exercise, title
        case videoLink = "video_link"
        case thumbURL
        case datePublication = "date_publication"
        case favoriteStatus = "favorite_status"
    }
}
