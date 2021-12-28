//
//  SettingTableDelegateDatasource.swift
//  VIKFIT
//

import Foundation
import UIKit
import MessageUI
import StoreKit
//MARK:- UITableViewDataSource
extension SettingVC :UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section0Titles.count
        } else if section == 3 {
            return section3Titles.count
        } else if section == 4 {
            return section4Titles.count
        } else if section == 5 {
            return section5.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingProfileTableCell", for: indexPath) as! SettingProfileTableCell
            cell.lblTitle.text = section0Titles[indexPath.row]
            cell.tfOfTitle.text = section0TextVelues[indexPath.row]
            cell.tfOfTitle.placeholder = section0placeHolder[indexPath.row]
            cell.tfOfTitle.tag = indexPath.row
            cell.tfOfTitle.delegate = self
            cell.tfOfTitle.autocapitalizationType = .sentences
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingSingleTextTableCell", for: indexPath) as! SettingSingleTextTableCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingDescriptionTableCell", for: indexPath) as! SettingDescriptionTableCell
            if discriptionTxt == "" {
                cell.tvDescription.text = Messages.txtSettingTextViewDesYourSelf
                cell.tvDescription.textColor = #colorLiteral(red: 0.1882352941, green: 0.1882352941, blue: 0.1882352941, alpha: 1)
            } else {
                cell.tvDescription.text = discriptionTxt
                cell.tvDescription.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            return cell
        case 3:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingSwitchTableCell", for: indexPath) as! SettingSwitchTableCell
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    cell.notiSwitch.isOn = isNoti
                } else {
                    cell.notiSwitch.isOn = false
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingProfileTableCell", for: indexPath) as! SettingProfileTableCell
                cell.lblTitle.text = section3Titles[indexPath.row]
                cell.tfOfTitle.delegate = self
                if indexPath.row == 1 {
                    cell.tfOfTitle.text = section3TextValues[indexPath.row]
                    cell.tfOfTitle.isUserInteractionEnabled = true
                    cell.tfOfTitle.keyboardType = .emailAddress
                    cell.tfOfTitle.tag = 3
                    cell.tfOfTitle.placeholder = "Your email".localized
                } else {
                    cell.tfOfTitle.text = section3TextValues[indexPath.row]
                    cell.tfOfTitle.isUserInteractionEnabled = false
                    cell.tfOfTitle.placeholder = "Your phone no".localized
                }
                return cell
            }
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingSingleTextTableCell", for: indexPath) as! SettingSingleTextTableCell
            cell.lblTitle.text = section4Titles[indexPath.row]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingAboutTableCell", for: indexPath) as! SettingAboutTableCell
            cell.imgOfTitle.image = section5[indexPath.row].icon
            cell.lblTitle.text = section5[indexPath.row].title
            cell.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.font = UIFont(name: "Poppins-Medium", size: 13)
        headerView.textLabel?.textColor = #colorLiteral(red: 0.6901960784, green: 0.6901960784, blue: 0.6901960784, alpha: 1)
    }
}
//MARK: Table View Delegates Method
extension SettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 160
        } else {
            return 56
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            return 2
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 2
        } else {
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            IAPManager.shared.startObserving()
            viewModel.restorePurchases()
        } else if indexPath.section == 3 {
            if indexPath.row == 2 {
                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "UpdatePhoneVC") as! UpdatePhoneVC
                aboutVC.settingsVC = self
                aboutVC.perivousNo = section3TextValues[2]
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
            }
        } else if indexPath.section == 4 {
            if indexPath.row == 0 {
                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PersionalizeVC") as! PersionalizeVC
                aboutVC.isFromSetting = true
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                    
                    let alert  = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.txtSettingTxtUnblockAllMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
                        self.apiUnblockAllUsers()
                    }))
                    alert.addAction(UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        } else if indexPath.section == 5 {
            switch section5[indexPath.row].identifire {
            case "FB" :
                Global.openURL(section5[indexPath.row].url)
                break
            case "INSTA" :
                Global.openURL(section5[indexPath.row].url)
                break
            case "SNAPCHAT" :
                Global.openURL(section5[indexPath.row].url)
                break
            case "SITE" :
                Global.openURL(section5[indexPath.row].url)
                break
            case "RATE" :
                SKStoreReviewController.requestReview()
                break
            case "REPORT" :
                showReportMessagePopup()
                break
            case "CONTACT" :
                sendMail(email: section5[indexPath.row].url)
                break
            case "TERMS" :
                let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.titleString = Messages.txtSec5TermService
                webViewController.url = section5[indexPath.row].url
                navigationController?.pushViewController(webViewController, animated: true)
                break
                
            case "PRIVACY" :
                let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.titleString = Messages.txtSec5PrivacyPolicy
                webViewController.url = section5[indexPath.row].url
                navigationController?.pushViewController(webViewController, animated: true)
                break
            default :
                break
            }
        }
    }
}

//MARK:-Table View Cell Class
class SettingAboutTableCell: UITableViewCell {
    @IBOutlet weak var imgOfTitle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
}

//MARK: Table View Cell Class
class SettingSingleTextTableCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
}

//MARK: Table View Cell Class
class SettingSwitchTableCell: UITableViewCell {
    @IBOutlet weak var notiSwitch: UISwitch!
}

//MARK: Table View Cell Class
class SettingDescriptionTableCell: UITableViewCell {
    @IBOutlet weak var tvDescription: UITextView!
}

//MARK: Table View Cell Class
class SettingProfileTableCell: UITableViewCell {
    @IBOutlet weak var tfOfTitle: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
}
