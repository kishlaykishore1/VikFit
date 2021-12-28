//
//  SettingExtensionAPI.swift
//  VIKFIT
//

import Foundation
import UIKit

//MARK: API Call
extension SettingVC {
    func apiGeneralSetting() {
        if let getRequest = API.GENERALSETTING.request(method: .post, with: [:], forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.GENERALSETTING.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        Constants.kAppDelegate.generalSettingsModal = try decoder.decode(GeneralSettingsModal.self, from: jsonData)
                        self.generalSettingsModal = try decoder.decode(GeneralSettingsModal.self, from: jsonData)
                        self.lblVersion.text = self.generalSettingsModal?.iosAppVersion
                        if self.generalSettingsModal?.facebookURLStatus ?? false {
                            let section = Section5(title: "Follow us on Facebook".localized, icon: #imageLiteral(resourceName: "fb"), identifire: "FB", url: self.generalSettingsModal?.facebookURL ?? "")
                            self.section5.append(section)
                        }
                        if self.generalSettingsModal?.instagramURLStatus ?? false {
                            let section = Section5(title: "Follow us on Instagram".localized, icon: #imageLiteral(resourceName: "insta"), identifire: "INSTA", url: self.generalSettingsModal?.instagramURL ?? "")
                            self.section5.append(section)
                            
                        }
                        if self.generalSettingsModal?.snapchatURLStatus ?? false {
                            let section = Section5(title: "Follow us on Snapchat".localized, icon: #imageLiteral(resourceName: "snapchat"), identifire: "SNAPCHAT", url: self.generalSettingsModal?.snapchatURL ?? "")
                            self.section5.append(section)
                        }
                        if self.generalSettingsModal?.websiteURLStatus ?? false {
                            let section = Section5(title: "See our website".localized, icon: #imageLiteral(resourceName: "site"), identifire: "SITE", url: self.generalSettingsModal?.websiteURL ?? "")
                            self.section5.append(section)
                        }
                        let section1 = Section5(title:"Rate the application".localized, icon: #imageLiteral(resourceName: "rateapp"), identifire: "RATE", url: "")
                        self.section5.append(section1)
                        let section2 = Section5(title: "Report a problem".localized, icon: #imageLiteral(resourceName: "report"), identifire: "REPORT", url: "")
                        self.section5.append(section2)
                        let section3 = Section5(title: "Contact us".localized, icon: #imageLiteral(resourceName: "envolop"), identifire: "CONTACT", url: self.generalSettingsModal?.conatctUs ?? "")
                        self.section5.append(section3)
                        let section4 = Section5(title: "Terms of Service".localized, icon: #imageLiteral(resourceName: "document"), identifire: "TERMS", url: self.generalSettingsModal?.terms ?? "")
                        self.section5.append(section4)
                        let section5 = Section5(title: "Privacy policy".localized, icon: #imageLiteral(resourceName: "policy"), identifire: "PRIVACY", url: self.generalSettingsModal?.privacy ?? "")
                        self.section5.append(section5)
                        self.tableView.reloadData()
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
    
    func apiUpdateProfile() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        
        if Validation.isBlank(for: section0TextVelues[0]) {
            Common.showAlertMessage(message: Messages.emptyFName, alertType: .error)
            return
        }
        if Validation.isBlank(for:  section0TextVelues[1]) {
            Common.showAlertMessage(message: Messages.emptyLName, alertType: .error)
            return
        }
        if Validation.isBlank(for: section0TextVelues[2]) {
            Common.showAlertMessage(message: Messages.emptyDob, alertType: .error)
            return
        }
        //        if Validation.isBlank(for: discriptionTxt) {
        //            Common.showAlertMessage(message: Messages.emptyDis, alertType: .error)
        //            return
        //        }
        if Validation.isBlank(for: section3TextValues[1]) {
            Common.showAlertMessage(message: Messages.emptyEmail, alertType: .error)
            return
        }
        if !Validation.isValidEmail(for: section3TextValues[1]) {
            Common.showAlertMessage(message: Messages.invalidEmail, alertType: .error)
            return
        }
        
        let param: [String: Any] = ["user_id": userId, "first_name": section0TextVelues[0], "last_name": section0TextVelues[1], "email": section3TextValues[1], "dob": convertDateFormater(section0TextVelues[2], "dd MMM yyyy", "yyyy-MM-dd"), "is_notification": "\(isNoti)", "bio": discriptionTxt]
        
        
        if let getRequest = API.UPDATEPROFILE.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.UPDATEPROFILE.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                    UserModel.storeUserModel(value: getData)
                    self.setData()
                    self.tableView.reloadData()
                    self.myProfileVC?.profileData()
                    self.dismiss(animated: true) {
                        self.myProfileVC?.profileData()
                    }
                })
            }
        }
    }
    
    func apiUnblockAllUsers() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param: [String: Any] = ["user_id": userId]
        
        
        if let getRequest = API.UNBLOCKALL.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.UNBLOCKALL.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                })
            }
        }
    }
    
    func apiBugReport(_ bug: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "bug": bug]
        
        if let getRequest = API.BUGREPORT.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.BUGREPORT.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: "Your message has been sent. Our teams will take care of it as soon as possible.".localized, alertType: .success)
                })
            }
        }
    }
    
    func logoutFromApp() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId]
        
        if let getRequest = API.LOGOUT.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.LOGOUT.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.logoutFromDevice()
                })
            }
        }
    }
    func apiDeleteAccount() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId]
        
        if let getRequest = API.DELETEACCOUNT.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.DELETEACCOUNT.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.logoutFromDevice()
                })
            }
        }
    }
}
