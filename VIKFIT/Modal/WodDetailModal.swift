//
//  WodDetailModal.swift
//  VIKFIT
//

import Foundation

// MARK: - WodDetailModal
struct WodDetailModal: Codable {
    let id, nameOfWod, difficulty, totalDuration: String
    let image: String
    let dateOfWod: String
    let linkDescription: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameOfWod = "name_of_wod"
        case difficulty
        case totalDuration = "total_duration"
        case image
        case dateOfWod = "date_of_wod"
        case linkDescription = "link_description"
    }
}
