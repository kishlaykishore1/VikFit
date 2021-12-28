//
//  EmailVC.swift
//  VIKFIT
//


import UIKit

class EmailVC: UIViewController {
    @IBOutlet weak var tfEmail: UITextField!
    var param: [String: Any] = [:]
    var profilePic = #imageLiteral(resourceName: "avtar")
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tfEmail.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        tfEmail.text = param["email"] as? String ?? ""
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        self.title = Messages.txtProfilePictureTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 12)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1)]
    }
    override func viewDidAppear(_ animated: Bool) {
        tfEmail.becomeFirstResponder()
    }
}
//MARK:- Button Action
extension EmailVC {
    //Mark: Back Button Tap Action
    override func backBtnTapAction() {
        self.navigationController?.popViewController(animated: true)
    }
    //Mark: Finish Button Action
    @IBAction func actionFinish(_ sender: UIButton) {
        gotoNext(txt: tfEmail.text?.trim() ?? "")
    }
    func gotoNext(txt: String) {
        if param["login_by"] as! String != "apple" || txt != "" {
            if Validation.isBlank(for: txt) {
                Common.showAlertMessage(message: Messages.txtEmailAlertMes, alertType: .error)
                return
            } else if !Validation.isValidEmail(for: txt) {
                Common.showAlertMessage(message: Messages.txtEmailValidAlertMes, alertType: .error)
                return
            }
            apiUniqueEmail(email: txt)
        } else {
            param["email"] = txt
            param["device_token"] = UserDefaults.standard.string(forKey: "deviceToken") ?? "5ed812dbccb12ea9a7a98fae0527c9642efb581a11bb54995f9b8fa022e8aef4"
            param["device_type"] = "ios"
            self.apiRegister(param)
        }
    }
}
//MARK:- Text field delegate Method
extension EmailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        gotoNext(txt: textField.text ?? "")
        return true
    }
}

//MARK: Api Calling
extension EmailVC {
    func apiUniqueEmail(email: String) {
        if let getRequest = API.UNIQUEEMAIL.request(method: .post, with: ["email": email], forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.UNIQUEEMAIL.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.param["email"] = email
                    self.param["device_token"] = UserDefaults.standard.string(forKey: "deviceToken") ?? "5ed812dbccb12ea9a7a98fae0527c9642efb581a11bb54995f9b8fa022e8aef4"
                    self.param["device_type"] = "ios"
                    self.apiRegister(self.param)
                })
            }
        }
    }
    
    func apiRegister(_ param: [String: Any]) {
        Global.showLoadingSpinner()
        API.REGISTER.requestUpload(with: param, files: ["image": self.profilePic]) { (response, error) in
            Global.dismissLoadingSpinner()
            guard error == nil, let getData = response?["data"] as? [String: Any] else {
                return
            }
            UserModel.storeUserModel(value: getData)
            UserDefaults.standard.set(true, forKey: "isSignup")
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "AdsVC") as! AdsVC
                if #available(iOS 13.0, *) {
                    aboutVC.isModalInPresentation = true
                }
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
                UserDefaults.standard.set(false, forKey: "isAdvt")
            } else {
                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "NotificationPermissionVC") as! NotificationPermissionVC
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                rootNavView.modalPresentationStyle = .fullScreen
                if #available(iOS 13.0, *) {
                    getNav.isModalInPresentation = true
                }
                getNav.present( rootNavView, animated: true, completion: nil)
            }
        }
    }
}
