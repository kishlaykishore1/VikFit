//
//  SettingVC.swift
//  VIKFIT
//

import UIKit
import IQKeyboardManagerSwift
import MessageUI

struct Section5 {
    var title: String
    var icon: UIImage
    var identifire: String
    var url: String
    init(title: String, icon: UIImage, identifire: String, url: String) {
        self.title = title
        self.icon = icon
        self.identifire = identifire
        self.url = url
    }
}

class SettingVC: UIViewController {
    
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var navBarBtnSaver: UIBarButtonItem!
    @IBOutlet weak var navBarBtnCancel: UIBarButtonItem!
    var discriptionTxt = ""
    var isNoti = true
    var viewModel = ViewModel()
    var myProfileVC: MyProfileVC?
    //MARK:date Picker Variable
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        let date = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        picker.maximumDate = date
        picker.locale = Locale(identifier: getLanguage())
        if let userData = UserModel.getUserModel() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: userData.dob) {
                picker.setDate(date, animated: true)
            }
        }
        return picker
    }()
    
    //MARK: PRIVATE PROPERTIES
    
    var generalSettingsModal: GeneralSettingsModal?
    var sections: [String] = [Messages.txtSectionProfile, "", Messages.txtSectionDescription, Messages.txtSectionSettings, "", Messages.txtSectionAboutUs]
    
    var section0Titles : [String] = [Messages.txtSection0FN, Messages.txtSection0LN, Messages.txtSection0DOB]
    var section0placeHolder : [String] = [Messages.txtPlaceHolderFN, Messages.txtPlaceHolderLN, Messages.txtPlaceHolderDOB]
    var section0TextVelues : [String] = ["", "", ""]
    
    var section3Titles : [String] = [Messages.txtSec3Noti, Messages.txtSec3Email, Messages.txtSec3PhNo]
    var section3TextValues : [String] = ["", "", ""]
    var section4Titles : [String] = [Messages.txtSec4ChangePS, Messages.txtSec4UnblockAll]
    
    var section5 = [Section5]()
    
    var section5Titles : [String] = [Messages.txtSec5FB, Messages.txtSec5Insta, Messages.txtSec5Snapchat, Messages.txtSec5Website, Messages.txtSec5Rate, Messages.txtSec5Report, Messages.txtSec5Contact, Messages.txtSec5TermService, Messages.txtSec5PrivacyPolicy]
    
    private var section5Images = [#imageLiteral(resourceName: "fb"), #imageLiteral(resourceName: "insta"), #imageLiteral(resourceName: "snapchat"), #imageLiteral(resourceName: "site"), #imageLiteral(resourceName: "rateapp"), #imageLiteral(resourceName: "report"), #imageLiteral(resourceName: "envolop"), #imageLiteral(resourceName: "document"), #imageLiteral(resourceName: "policy")]
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        apiGeneralSetting()
        
    }
    @objc func willEnterForeground() {
        setData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hideKeyboardWhenTappedAround()
        self.navigationController?.isNavigationBarHidden = false
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        IQKeyboardManager.shared.enableAutoToolbar = true
        self.title = Messages.txtSettingVCTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 18)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)]
        navBarBtnSaver.setTitleTextAttributes (
            [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 15)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)], for: .normal)
        navBarBtnCancel.setTitleTextAttributes (
            [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 15)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)], for: .normal)
        
        //Mark: FooterView Configuration
        self.tableView.tableFooterView = footerView
        self.tableView.tableFooterView?.frame = footerView.frame
        setData()
        
    }
    
    func setData() {
        if let userData = UserModel.getUserModel() {
            if userData.bio != "" {
                discriptionTxt = userData.bio
            }
            
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        self.isNoti =  true
                        self.tableView.reloadData()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.isNoti = false
                        self.tableView.reloadData()
                    }
                }
            }
            
            //            if UIApplication.shared.isRegisteredForRemoteNotifications {
            //              isNoti =  true//userData.isNotification
            //            } else {
            //               isNoti = false
            //            }
            section0TextVelues[0] = userData.firstName
            section0TextVelues[1] = userData.lastName
            if userData.dob != "" {
                section0TextVelues[2] = convertDateFormater(userData.dob, "yyyy-MM-dd", "dd MMM yyyy")
            } else {
                section0TextVelues[2] = ""
            }
            section3TextValues[1] = userData.email
            section3TextValues[2] = userData.phoneNumber
            tableView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        //        if UIApplication.shared.isRegisteredForRemoteNotifications {
        //          isNoti = sender.isOn
        //        } else {
        //            sender.isOn = false
        //             isNoti = false
        //            DispatchQueue.main.async {
        //                let alert  = UIAlertController(title: "Activate notifications".localized, message: "You need to enable notifications in the app settings.".localized, preferredStyle: .alert)
        //                alert.addAction(UIAlertAction(title: "Settings".localized, style: .default, handler: { _ in
        //                         if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
        //                             if UIApplication.shared.canOpenURL(appSettings) {
        //                                 UIApplication.shared.open(appSettings)
        //                             }
        //                         }
        //                     }))
        //                     alert.addAction(UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel, handler: nil))
        //                     self.present(alert, animated: true, completion: nil)
        //                 }
        //        }
        //
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    self.isNoti = sender.isOn
                    self.tableView.reloadData()
                }
            }
            else {
                DispatchQueue.main.async {
                    sender.isOn = false
                    self.isNoti = false
                    self.tableView.reloadData()
                    let alert  = UIAlertController(title: "Activate notifications".localized, message: "You need to enable notifications in the app settings.".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Settings".localized, style: .default, handler: { _ in
                        if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                            if UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
}
//MARK:- Button Actions
extension SettingVC {
    //Mark: Action For Delete Account
    @IBAction func actionDeleteAccount(_ sender: UIButton) {
        DispatchQueue.main.async {
            let alert  = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.deleteAccountMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
                self.deleteAccountFromServer()
            }))
            alert.addAction(UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //Mark: Action on Cancel Tapped
    @IBAction func actiontapCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.myProfileVC?.profileData()
        }
    }
    //Mark: Action on Save Tapped
    @IBAction func actionTapSave(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        apiUpdateProfile()
    }
    //Mark: Action on Logout Tapped
    @IBAction func actionLogout(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            let alert  = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.logoutMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
                self.logoutFromServer()
            }))
            alert.addAction(UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: Delete Account
    func deleteAccountFromServer() {
        self.apiDeleteAccount()
    }
    
    //MARK: Logout From the server
    func logoutFromServer() {
        self.logoutFromApp()
    }
    //MARK: Logout From the Device
    func logoutFromDevice() {
        Global.clearAllAppUserDefaults()
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.isUserLogin(false)
            }
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.isUserLogin(false)
        }
    }
}
//MARK:- Text field Delegate Methods
extension SettingVC :UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            textField.inputView = datePicker
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            section0TextVelues[0] = textField.text ?? ""
            
        } else if textField.tag == 1 {
            section0TextVelues[1] = textField.text ?? ""
            
        } else if textField.tag == 2 {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.none
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateFormatter.locale = Locale(identifier: getLanguage())
            let date = dateFormatter.string(from: self.datePicker.date)
            section0TextVelues[2] = date
            textField.text = date
        } else if textField.tag == 3 {
            section3TextValues[1] = textField.text ?? ""
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

//MARK: Report Popup
extension SettingVC {
    func showReportMessagePopup() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: Messages.txtSettingReportBug, message: Messages.bugReportTitle, preferredStyle: .alert)
            let saveAction = UIAlertAction(title: Messages.txtSettingSend, style: .destructive, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                if firstTextField.text?.trim().count == 0 {
                    Common.showAlertMessage(message: Messages.txtSettingBugDetail, alertType: .error)
                    return
                }
                self.apiBugReport(firstTextField.text!)
            })
            let cancelAction = UIAlertAction(title: Messages.txtDeleteCancel, style: .default, handler: { (action : UIAlertAction!) -> Void in
                
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                saveAction.isEnabled = false
                textField.placeholder = Messages.txtSettingReportTextField
                textField.autocapitalizationType = .sentences
                textField.isEnabled = false
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                    {_ in
                        let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                        let textIsNotEmpty = textCount > 0
                        saveAction.isEnabled = textIsNotEmpty
                        
                })
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            self.present(alertController, animated: true, completion: {
                let firstTextField = alertController.textFields![0] as UITextField
                firstTextField.isEnabled = true
                firstTextField.becomeFirstResponder()
                
            })
        }
    }
}
//MARK:- Text View Delegate Methods
extension SettingVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if  textView.text == Messages.txtSettingTextViewDesYourSelf {
            textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Messages.txtSettingTextViewDesYourSelf
            textView.textColor = #colorLiteral(red: 0.1882352941, green: 0.1882352941, blue: 0.1882352941, alpha: 1)
        } else {
            discriptionTxt = textView.text
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        if updatedText.isEmpty {
            textView.text = Messages.txtSettingTextViewDesYourSelf 
            textView.textColor = #colorLiteral(red: 0.1882352941, green: 0.1882352941, blue: 0.1882352941, alpha: 1)
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == #colorLiteral(red: 0.1882352941, green: 0.1882352941, blue: 0.1882352941, alpha: 1) && !text.isEmpty {
            textView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            textView.text = ""
            discriptionTxt = textView.text
            return true
        } else {
            discriptionTxt = textView.text
            return true
        }
        return false
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == #colorLiteral(red: 0.1882352941, green: 0.1882352941, blue: 0.1882352941, alpha: 1) {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}


//MARK: Send Mail
extension SettingVC: MFMailComposeViewControllerDelegate {
    func sendMail(email: String) {
        if !MFMailComposeViewController.canSendMail() {
            Common.showAlertMessage(message: Messages.mailNotFound, alertType: .warning)
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["contact@vikfit.co"])
        composeVC.setSubject("Request contact".localized)
        composeVC.setMessageBody("", isHTML: false)
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
