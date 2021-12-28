//
//  WODModal.swift
//  VIKFIT
//

import Foundation

// MARK: - WODModal
struct WODModal: Codable {
    let title: String
    let isVideo: Bool
    let type: String
    let data: [ListDataArr]
    let isNutrition: Bool?
    
    enum CodingKeys: String, CodingKey {
        case title
        case isVideo = "is_video"
        case type, data
        case isNutrition = "is_nutrition"
    }
}

// MARK: - Datum
struct ListDataArr: Codable {
    let id: String
    let nameOfWod, difficulty, totalDuration: String?
    let image: String?
    let dateOfWod: String?
    let isUnloked, isFirst: Bool?
    let title, datePublication, exercise: String?
    let videoLink: String?
    let thumbURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameOfWod = "name_of_wod"
        case difficulty
        case totalDuration = "total_duration"
        case image
        case dateOfWod = "date_of_wod"
        case isUnloked = "is_unloked"
        case isFirst = "is_first"
        case title
        case datePublication = "date_publication"
        case exercise
        case videoLink = "video_link"
        case thumbURL
    }
}
