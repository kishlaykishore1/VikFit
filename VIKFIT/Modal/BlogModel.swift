//
//  BlogModel.swift
//  VIKFIT
//


import Foundation

// MARK: - BlogModel
struct BlogModel: Codable {
    let id, title, datePublication: String

    enum CodingKeys: String, CodingKey {
        case id, title
        case datePublication = "date_publication"
    }
}

// MARK: - BlogModal detail
struct BlogModal: Codable {
        let id, title, category, author: String
        let blogDescription: String
        let linkDescription: String
        let image: String
        let datePublication: String

        enum CodingKeys: String, CodingKey {
            case id, title, category, author
            case blogDescription = "description"
            case linkDescription = "link_description"
            case image
            case datePublication = "date_publication"
        }
    }
