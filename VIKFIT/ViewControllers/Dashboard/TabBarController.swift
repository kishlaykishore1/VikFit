
import UIKit
import SPStorkController

class TabBarController: UITabBarController, EasyTipViewDelegate, UITabBarControllerDelegate {
    var preferences = EasyTipView.Preferences()
    public var tipView: EasyTipView?
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        //MARK:Tool Tip For Tab Bar
        DispatchQueue.main.async {
            self.preferences.drawing.font = UIFont(name: "HelveticaNeue-Medium", size: 14)!
            self.preferences.drawing.foregroundColor = UIColor.white
            self.preferences.drawing.textAlignment = .left
            self.preferences.drawing.isGradient = true
            self.preferences.drawing.colorGradient = [#colorLiteral(red: 0.2588235294, green: 0.6901960784, blue: 1, alpha: 1) ,#colorLiteral(red: 0, green: 0.4274509804, blue: 0.9294117647, alpha: 1)]
            self.preferences.drawing.arrowHeight = 12
            self.preferences.drawing.arrowWidth = 20
            self.preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
            self.preferences.positioning.bubbleHInset = 150
            self.preferences.positioning.bubbleHOffset = 120
            
            self.tipView = EasyTipView(text: "Chat with community members and stay motivated. 😜".localized, preferences:  self.preferences, delegate: self)
            if !UserDefaults.standard.bool(forKey: "isToolTipHide") {
                self.tipView?.show(animated: true, forView: self.tabBar, withinSuperview: self.view)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isAdvt") {
            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "AdsVC") as! AdsVC
            //            if #available(iOS 13.0, *) {
            //                aboutVC.isModalInPresentation = true
            //            }
            aboutVC.fromHome = true
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
            UserDefaults.standard.set(false, forKey: "isAdvt")
        }
    }
    //MARK:Tool Tip Dismisall Method
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tipView?.dismiss()
        UserDefaults.standard.set(true, forKey: "isToolTipHide")
        guard let conroller = self.viewControllers?[0] as? WodsVC else {
            return
        }
        conroller.dismissTooltips()
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if UserModel.getUserModel() == nil {
            let loginVC = StoryBoard.Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let transitionDelegate = SPStorkTransitioningDelegate()
            loginVC.transitioningDelegate = transitionDelegate
            loginVC.modalPresentationStyle = .custom
            loginVC.modalPresentationCapturesStatusBarAppearance = true
            transitionDelegate.showIndicator = false
            self.present(loginVC, animated: true, completion: nil)
            return false
        }
//        else {
//            if viewController == self.viewControllers?[2] as? NewsFeedsVC {
//                guard let receiptInfo = UserDefaults.standard.object(forKey: "ReceiptInfo") as? [String: Any] else {
//                    Common.showAlertMessage(message: Messages.mustSubscribe, alertType: .warning)
//                    let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
//                    aboutVC.isFromHome = true
//                    guard let getNav = UIApplication.topViewController()?.navigationController else {
//                        return false
//                    }
//                    let rootNavView = UINavigationController(rootViewController: aboutVC)
//                    rootNavView.modalPresentationStyle = .fullScreen
//                    if #available(iOS 13.0, *) {
//                        getNav.isModalInPresentation = true
//                    }
//                    getNav.present( rootNavView, animated: true, completion: nil)
//                    return false
//                }
//                if  receiptInfo["type"] as? String == "free" {
//                    Common.showAlertMessage(message: Messages.mustSubscribe, alertType: .warning)
//                    let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
//                    aboutVC.isFromHome = true
//                    guard let getNav = UIApplication.topViewController()?.navigationController else {
//                        return false
//                    }
//                    let rootNavView = UINavigationController(rootViewController: aboutVC)
//                    rootNavView.modalPresentationStyle = .fullScreen
//                    if #available(iOS 13.0, *) {
//                        getNav.isModalInPresentation = true
//                    }
//                    getNav.present( rootNavView, animated: true, completion: nil)
//                    return false
//                }
//            }
//            return true
//        }
        
        return true
    }
}
