//
//  LoginVC.swift
//  VIKFIT
//


import UIKit
import AuthenticationServices
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import Firebase
import GoogleSignIn
import FirebaseAuth
import ADCountryPicker

class LoginVC: UIViewController {
    
    @IBOutlet weak var tfPhoneNo: UITextField!
    @IBOutlet weak var lblContryCode: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblTermsNService: TTTAttributedLabel!
    var welcomeVC: WelcomeVC?
    let picker = ADCountryPicker()
    var txtCode = "+33"
    var param: [String: Any] = [:]
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setup()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        picker.searchBarBackgroundColor = UIColor.white
        picker.hidesNavigationBarWhenPresentingSearch = false
        picker.defaultCountryCode = "FR"
        picker.delegate = self
        hideKeyboardWhenTappedAround()
        lblContryCode.text = "\(emojiFlag(regionCode: "FR")!) +33"
        DispatchQueue.main.async {
            self.backView.roundCorners([.topLeft, .topRight], radius: 18)
        }
    }
}

//MARK:- Button Actions
extension LoginVC {
    //Mark: login Action
    @IBAction func actionLogin(_ sender: DesignableButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if !Validation.isValidMobileNumber(value: tfPhoneNo.text ?? "") {
            Common.showAlertMessage(message: "Please enter valid phone no".localized, alertType: .error)
            return
        }
        Global.showLoadingSpinner()
        PhoneAuthProvider.provider().verifyPhoneNumber("\(txtCode)\(tfPhoneNo.text!)", uiDelegate: nil) { (verificationID, error) in
            Global.dismissLoadingSpinner()
            if error != nil {
                Common.showAlertMessage(message: "Please enter valid phone no or contry code".localized, alertType: .error)
                return
            }
            self.dismiss(animated: true) {
                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "OTPVC") as! OTPVC
                aboutVC.welcomeVC = self.welcomeVC
                aboutVC.verificationID = verificationID ?? ""
                aboutVC.mobileNo = "\(self.txtCode)\(self.tfPhoneNo.text!)"
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func actionContinueWithApple(_ sender: UIControl) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            let alert = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.txtAppleSignInMes, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Messages.txtDissmiss, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionContinueWithGoogle(_ sender: UIControl) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Global.showLoadingSpinner()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func actionContinueWithFacebook(_ sender: UIControl) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        print("facebook action Btn")
        self.facebookLogin()
    }
    @IBAction func actionSkip(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
            self.dismiss(animated: true) {
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
        }
        //apiUserSkipLogin()
    }
    @IBAction func actionRegistration(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.dismiss(animated: true) {
            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "ProfilePictureVC") as! ProfilePictureVC
            aboutVC.welcomeVC = self.welcomeVC
            aboutVC.param = ["avatar": "", "login_by": "manual"]
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            if #available(iOS 13.0, *) {
                aboutVC.isModalInPresentation = true
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
            
        }
    }
    @IBAction func actionSelectCountry(_ sender: UIControl) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
    }
    
}
extension LoginVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        Global.dismissLoadingSpinner()
        if error != nil {
            return
        }
        let userId = user.userID ?? ""
        let givenName = user.profile.givenName ?? ""
        let familyName = user.profile.familyName ?? ""
        let email = user.profile.email ?? ""
        let url = "\(user.profile.imageURL(withDimension: 200)!)"
        apiSocialLogin(email: email, firstName: givenName, lastName: familyName, uniqueID: userId, loginBy: "google", imgUrl: url)
        GIDSignIn.sharedInstance()?.signOut()
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
//MARK:- Authorization Controller Delegate
@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            apiSocialLogin(email: appleIDCredential.email ?? "", firstName: appleIDCredential.fullName?.givenName ?? "", lastName:  appleIDCredential.fullName?.familyName ?? "", uniqueID: appleIDCredential.user, loginBy: "apple", imgUrl: "")
        }
    }
    
    // Authorization Failed
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
}

//MARK:-  For present window
@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

//
//MARK: Facebook Login
//
extension LoginVC {
    
    //Social login
    private func facebookLogin() {
        if let accressToken = AccessToken.current {
            print("Facebook User Access Token: \(accressToken)")
            self.getFBUserData()
        }
        
        if AccessToken.current == nil {
            LoginManager().logIn(permissions: ["email"], from: self) { (result, error) -> Void in
                if (error == nil) {
                    let fbloginresult : LoginManagerLoginResult = result!
                    // if user cancel the login
                    if (result?.isCancelled) ?? false {
                        print("Facebook User Cancelled")
                        return
                    }
                    
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        self.getFBUserData()
                        print(AccessToken.current!.tokenString as Any)
                    }
                }
            }
        }
    }
    private func getFBUserData() {
        if((AccessToken.current) != nil) {
            Global.showLoadingSpinner()
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, response, error) -> Void in
                Global.dismissLoadingSpinner()
                if (error == nil) {
                    print(response as Any)
                    if let result = response as? [String : Any] {
                        let email = result["email"] as? String ?? ""
                        let firstName = result["first_name"] as? String ?? ""
                        let id = result["id"] as? String ?? ""
                        let lastName = result["last_name"] as? String ?? ""
                        self.apiSocialLogin(email: email, firstName: firstName, lastName: lastName, uniqueID: id, loginBy: "facebook", imgUrl: "https://graph.facebook.com/\(id)/picture?type=large")
                        LoginManager().logOut()
                    }
                    
                }
                
            })
        }
    }
}

extension LoginVC: ADCountryPickerDelegate {
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        txtCode = dialCode
        lblContryCode.text = "\(emojiFlag(regionCode: code)!) \(dialCode)"
        picker.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.tfPhoneNo.becomeFirstResponder()
            }
        }
    }
    
    func emojiFlag(regionCode: String) -> String? {
        let code = regionCode.uppercased()
        
        guard Locale.isoRegionCodes.contains(code) else {
            return nil
        }
        
        var flagString = ""
        for s in code.unicodeScalars {
            guard let scalar = UnicodeScalar(127397 + s.value) else {
                continue
            }
            flagString.append(String(scalar))
        }
        return flagString
    }
}


//MARK: API Calling
extension LoginVC {
    func apiSocialLogin(email: String, firstName: String, lastName: String, uniqueID: String, loginBy: String, imgUrl: String) {
        let param: [String : Any] = ["social_unique_id": uniqueID ,"device_token": UserDefaults.standard.string(forKey: "deviceToken") ?? "5ed812dbccb12ea9a7a98fae0527c9642efb581a11bb54995f9b8fa022e8aef4", "login_by": loginBy, "device_type": "ios"]
        if let getRequest = API.SOCIAL.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.SOCIAL.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    guard let getData = jsonObject?["data"] as? [String: Any] else {
                        self.dismiss(animated: true) {
                            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "ProfilePictureVC") as! ProfilePictureVC
                            aboutVC.welcomeVC = self.welcomeVC
                            aboutVC.param = ["email": email, "first_name": firstName, "last_name":  lastName, "social_unique_id": uniqueID, "avatar": imgUrl, "login_by": loginBy]
                            guard let getNav = UIApplication.topViewController()?.navigationController else {
                                return
                            }
                            if #available(iOS 13.0, *) {
                                aboutVC.isModalInPresentation = true
                            }
                            let rootNavView = UINavigationController(rootViewController: aboutVC)
                            getNav.present( rootNavView, animated: true, completion: nil)
                        }
                        return
                    }
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
                        self.dismiss(animated: true) {
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
                    }
                })
                
            }
        }
    }
}


//MARK:- TermsOfUse Label Set
extension LoginVC {
    func setup() {
        lblTermsNService.numberOfLines = 0;
        let txt1 = "By pressing Continue you acknowledge having read our".localized
        let txt2 = "and you accept our".localized
        
        let strPP = Messages.txtPPNewsFeed
        let strTC = Messages.txtTCNewsFeed
        let string = "\(txt1) \(strPP) \(txt2) \(strTC)"
        
        let nsString = string as NSString
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        
        let fullAttributedString = NSAttributedString(string:string, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            NSAttributedString.Key.font: UIFont.init(name: "Poppins-Medium", size: 11) ?? UIFont()
        ])
        
        lblTermsNService.textAlignment = .center
        lblTermsNService.attributedText = fullAttributedString
        
        let rangeTC = nsString.range(of: strTC)
        let rangePP = nsString.range(of: strPP)
        
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue: UIFont.init(name: "Poppins-SemiBold", size: 11) ?? UIFont()
        ]
        
        lblTermsNService.activeLinkAttributes = ppLinkAttributes
        lblTermsNService.linkAttributes = ppLinkAttributes
        
        let urlTC = URL(string: "action://TC")!
        let urlPP = URL(string: "action://PP")!
        lblTermsNService.addLink(to: urlTC, with: rangeTC)
        lblTermsNService.addLink(to: urlPP, with: rangePP)
        
        lblTermsNService.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lblTermsNService.delegate = self
    }
}

//MARK:- TTTAttributedLabelDelegate
extension LoginVC: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "action://TC" {
            self.dismiss(animated: true) {
                let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.titleString = Messages.txtSec5TermService
                webViewController.flag = true
                webViewController.welcomeVC = self.welcomeVC
                webViewController.url = Constants.kAppDelegate.generalSettingsModal?.terms ?? ""
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: webViewController)
                getNav.present( rootNavView, animated: true, completion: nil)
                
            }
        } else {
            self.dismiss(animated: true) {
                let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.titleString = Messages.txtSec5PrivacyPolicy
                webViewController.url = Constants.kAppDelegate.generalSettingsModal?.privacy ?? ""
                webViewController.flag = true
                webViewController.welcomeVC = self.welcomeVC
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: webViewController)
                getNav.present( rootNavView, animated: true, completion: nil)}
        }
    }
}
