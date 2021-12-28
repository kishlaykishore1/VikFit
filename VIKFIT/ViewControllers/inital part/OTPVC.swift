//
//  OTPVC.swift
//  VIKFIT
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseAuth

class OTPVC: UIViewController {
    @IBOutlet weak var txtHeading: UILabel!
    @IBOutlet weak var otpView: OTPInputView!
    var welcomeVC: WelcomeVC?
    var settingsVC: SettingVC?
    var isUpdate = false
    var verificationID: String = ""
    var mobileNo = ""
//    var btnTap = false
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        otpView.delegateOTP = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        txtHeading.text = "\(Messages.txtOtpVCMobileConfirm)\n\(mobileNo)"
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        self.title = Messages.txtOtpVCTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 12)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1)]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        otpView.becomeFirstResponder()
    }
    
    @IBAction func actionResendCode(_ sender: UIButton) {
        Global.showLoadingSpinner()
        PhoneAuthProvider.provider().verifyPhoneNumber(mobileNo, uiDelegate: nil) { (verificationID, error) in
            Global.dismissLoadingSpinner()
            if let error = error {
                print(error)
                return
            }
            Common.showAlertMessage(message: Messages.txtOtpVCCodeResent, alertType: .success)
            self.verificationID = verificationID ?? ""
        }
    }
}
//MARK:- Button Actions
extension OTPVC {
    //Mark: Back Button Tap Action
    override func backBtnTapAction() {
        if isUpdate {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true) {
                self.welcomeVC?.openLoginOptions()
            }
        }
    }
    //Mark: Otp Confirm button Action
    @IBAction func actionOtpConfirm(_ sender: UIButton) {
//        btnTap = true
        otpView.otpFetch()
    }
}

extension OTPVC: OTPViewDelegate {
    func didFinishedEnterOTP(otpNumber: String) {
//        if btnTap {
//            btnTap = false
            Global.showLoadingSpinner()
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID , verificationCode: otpNumber)
            Auth.auth().signIn(with: credential) { (authData, error) in
                Global.dismissLoadingSpinner()
                guard error == nil else {
                    Common.showAlertMessage(message: Messages.txtOtpvcValidCode, alertType: .error)
                    return
                }
                
                if self.isUpdate {
                    self.apiUpdatePhone(phoneNo: authData?.user.phoneNumber ?? "")
                } else {
                    self.apiUserLogin(phoneNo: authData?.user.phoneNumber ?? "")
                }
            }
//        }
    }
    
    func otpNotValid() {
        Common.showAlertMessage(message: Messages.txtOtpvcValidCode, alertType: .error)
    }
}

//MARK: API Calling
extension OTPVC {
    func apiUserLogin(phoneNo: String) {
        let param: [String : Any] = ["phone_number": phoneNo, "device_token": UserDefaults.standard.string(forKey: "deviceToken") ?? "5ed812dbccb12ea9a7a98fae0527c9642efb581a11bb54995f9b8fa022e8aef4", "device_type": "ios"]
        if let getRequest = API.LOGIN.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.LOGIN.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    guard let getData = jsonObject?["data"] as? [String: Any] else {
                        self.dismiss(animated: true, completion: {
                            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "ProfilePictureVC") as! ProfilePictureVC
                            aboutVC.welcomeVC = self.welcomeVC
                            aboutVC.mobileNo = phoneNo
                            aboutVC.param = ["avatar": "", "login_by": "manual"]
                            guard let getNav = UIApplication.topViewController()?.navigationController else {
                                return
                            }
                            if #available(iOS 13.0, *) {
                                aboutVC.isModalInPresentation = true
                            }
                            let rootNavView = UINavigationController(rootViewController: aboutVC)
                            getNav.present( rootNavView, animated: true, completion: nil)
                        })
                        return
                    }
                    
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                    UserModel.storeUserModel(value: getData)
                   if UIApplication.shared.isRegisteredForRemoteNotifications {
                        if #available(iOS 13.0, *) {
                            let scene = UIApplication.shared.connectedScenes.first
                            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                                sd.isUserLogin(true)
                            }
                        } else {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.isUserLogin(true)
                        }
                    } else {
                            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "NotificationPermissionVC") as! NotificationPermissionVC
                            guard let getNav = UIApplication.topViewController()?.navigationController else {
                                return
                            }
                            aboutVC.fromSkip = true
                            let rootNavView = UINavigationController(rootViewController: aboutVC)
                            rootNavView.modalPresentationStyle = .fullScreen
                            if #available(iOS 13.0, *) {
                                getNav.isModalInPresentation = true
                            }
                            getNav.present( rootNavView, animated: true, completion: nil)
                    }
                })
                
            }
        }
    }
    
    func apiUpdatePhone(phoneNo: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param: [String : Any] = ["phone_number": phoneNo, "user_id": userId]
        if let getRequest = API.PHONEUPDATE.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.PHONEUPDATE.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any]  else {
                        return
                    }
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                    UserModel.storeUserModel(value: getData)
                    self.settingsVC?.setData()
                    self.dismiss(animated: true) {
                        IQKeyboardManager.shared.enableAutoToolbar = true
                    }
                })
                
            }
        }
    }
}
