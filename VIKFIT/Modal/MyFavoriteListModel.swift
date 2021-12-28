//
//  MyFavoriteListModel.swift
//  VIKFIT
//

import Foundation

// MARK: - MyFavoriteListModel
struct MyFavoriteListModel: Codable {
    let id, exercise, title: String
    let videoLink: String
    let thumbURL: String
    let datePublication: String

    enum CodingKeys: String, CodingKey {
        case id, exercise, title
        case videoLink = "video_link"
        case thumbURL
        case datePublication = "date_publication"
    }
}
