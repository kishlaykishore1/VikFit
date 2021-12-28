//
//  GeneralSettingsModal.swift
//  VIKFIT
//

import Foundation

// MARK: - GeneralSettingsModal
struct GeneralSettingsModal: Codable {
    
     let siteName, expeditorEmail, administratorEmail, conatctUs: String
    let supportEmail, reportEmails: String
    let updateAndroidApp: Bool
    let androidAppVersion: String
    let updateIosApp: Bool
    let iosAppVersion: String
    let notifyNewUpdate: Bool
    let websiteURL, facebookURL, instagramURL, twitterURL: String
    let linkedinURL, snapchatURL: String
    let websiteURLStatus, facebookURLStatus, instagramURLStatus, twitterURLStatus: Bool
    let linkedinURLStatus, snapchatURLStatus: Bool
    let terms, privacy: String

    enum CodingKeys: String, CodingKey {
        case siteName = "site_name"
        case expeditorEmail = "expeditor_email"
        case administratorEmail = "administrator_email"
        case conatctUs = "conatct_us"
        case supportEmail = "support_email"
        case reportEmails = "report_emails"
        case updateAndroidApp = "update_android_app"
        case androidAppVersion = "android_app_version"
        case updateIosApp = "update_ios_app"
        case iosAppVersion = "ios_app_version"
        case notifyNewUpdate = "notify_new_update"
        case websiteURL = "website_url"
        case facebookURL = "facebook_url"
        case instagramURL = "instagram_url"
        case twitterURL = "twitter_url"
        case linkedinURL = "linkedin_url"
        case snapchatURL = "snapchat_url"
        case websiteURLStatus = "website_url_status"
        case facebookURLStatus = "facebook_url_status"
        case instagramURLStatus = "instagram_url_status"
        case twitterURLStatus = "twitter_url_status"
        case linkedinURLStatus = "linkedin_url_status"
        case snapchatURLStatus = "snapchat_url_status"
        case terms, privacy
    }
}
