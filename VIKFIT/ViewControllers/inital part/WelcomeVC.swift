//
//  WelcomeVC.swift
//  VIKFIT
//

import UIKit
import SPStorkController
import AuthenticationServices
class WelcomeVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var btnSignInApple: DesignableButton!
    @IBOutlet weak var lblTermsNService: TTTAttributedLabel!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setup()
    }
}

//MARK:- Button Action
extension WelcomeVC {
    // login Function
    func openLoginOptions() {
        let loginVC = StoryBoard.Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let transitionDelegate = SPStorkTransitioningDelegate()
        loginVC.transitioningDelegate = transitionDelegate
        loginVC.modalPresentationStyle = .custom
        loginVC.welcomeVC = self
        loginVC.modalPresentationCapturesStatusBarAppearance = true
        transitionDelegate.showIndicator = false
        self.present(loginVC, animated: true, completion: nil)
    }
    
    //Already Registered Button Action
    @IBAction func actionAlreadyRegistered(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        openLoginOptions()
    }
    
    //Login With Apple Button Action
    @IBAction func actionLoginWithApple(_ sender: UIButton) {
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
            alert.addAction(UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: Messages.txtOtherLoginMes, style: .default, handler: { _ in
                self.openLoginOptions()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //Other Login Button Action
    @IBAction func actionOtherLoginOption(_ sender: UIButton) {
        openLoginOptions()
    }
}

//MARK:- Authorization Controller Delegate
@available(iOS 13.0, *)
extension WelcomeVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            apiAppleLogin(email: appleIDCredential.email ?? "", firstName: appleIDCredential.fullName?.givenName ?? "", lastName:  appleIDCredential.fullName?.familyName ?? "", AId: appleIDCredential.user)
        }
    }
    
    // Authorization Failed
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func apiAppleLogin(email: String, firstName: String, lastName: String, AId: String) {
        let param: [String : Any] = ["social_unique_id": AId ,"device_token": UserDefaults.standard.string(forKey: "deviceToken") ?? "5ed812dbccb12ea9a7a98fae0527c9642efb581a11bb54995f9b8fa022e8aef4", "login_by": "apple", "device_type": "ios"]
        if let getRequest = API.SOCIAL.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.SOCIAL.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    guard let getData = jsonObject?["data"] as? [String: Any] else {
                        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "ProfilePictureVC") as! ProfilePictureVC
                        aboutVC.param = ["email": email, "first_name": firstName, "last_name": lastName, "social_unique_id": AId, "avatar": "", "login_by": "apple"]
                        guard let getNav = UIApplication.topViewController()?.navigationController else {
                            return
                        }
                        aboutVC.isModalInPresentation = true
                        let rootNavView = UINavigationController(rootViewController: aboutVC)
                        getNav.present( rootNavView, animated: true, completion: nil)
                        return
                    }
                    
                    UserModel.storeUserModel(value: getData)
                    if UIApplication.shared.isRegisteredForRemoteNotifications {
                        let scene = UIApplication.shared.connectedScenes.first
                        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                            sd.isUserLogin(true)
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
                            getNav.isModalInPresentation = true
                            getNav.present( rootNavView, animated: true, completion: nil)
                            
                        }
                    }
                })
                
            }
        }
    }
}

//MARK:-  For present window
@available(iOS 13.0, *)
extension WelcomeVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

//MARK:- TermsOfUse Label Set
extension WelcomeVC {
    func setup() {
        lblTermsNService.numberOfLines = 0;
        
        let strPP = Messages.txtPPNewsFeed
        let strTC = Messages.txtTCNewsFeed
        let string = "\(Messages.txtPpTcMesNewsFeed) \(strPP) \(Messages.txtPpTcMesNewsFeed1) \(strTC)"
        
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
extension WelcomeVC: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "action://TC" {
            let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.titleString = Messages.txtSec5TermService
            webViewController.flag = true
            webViewController.url = Constants.kAppDelegate.generalSettingsModal?.terms ?? ""
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: webViewController)
            getNav.present( rootNavView, animated: true, completion: nil)
        } else {
            let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.titleString = Messages.txtSec5PrivacyPolicy
            webViewController.url = Constants.kAppDelegate.generalSettingsModal?.privacy ?? ""
            webViewController.flag = true
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: webViewController)
            getNav.present( rootNavView, animated: true, completion: nil)
        }
    }
}
