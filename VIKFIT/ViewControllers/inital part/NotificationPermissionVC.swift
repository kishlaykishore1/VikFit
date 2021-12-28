//
//  NotificationPermissionVC.swift
//  VIKFIT
//

import UIKit
import UserNotifications

class NotificationPermissionVC: UIViewController {
    //MARK:Life Cycle
    var fromSkip = false
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func updateToken(_ deviceToken: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = [ "user_id": userId, "device_token": deviceToken]
        print(param)
        if let getRequest = API.UPDATETOKEN.request(method: .post, with: param, forJsonEncoding: true) {
            getRequest.responseJSON { (_) in
            }
        }
    }
}
//MARK:-Button Actions
extension NotificationPermissionVC {
    //Mark:Action For Skip Button
    @IBAction func actionBtnSkip(_ sender: UIButton) {
        askForPermission()
    }
    //Mark:Action For Permission Button
    @IBAction func actionPermission(_ sender: UIButton) {
        askForPermission()
        
    }
    
    func askForPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error != nil {
                // Handle the error here.
            }
            self.updateToken(UserDefaults.standard.string(forKey: "deviceToken") ?? "5ed812dbccb12ea9a7a98fae0527c9642efb581a11bb54995f9b8fa022e8aef4")
             DispatchQueue.main.async {
            self.dismiss(animated: true) {
                    if self.fromSkip {
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
                    }
                }
                
            }
        }
        Constants.kAppDelegate.kApplication?.registerForRemoteNotifications()
        
    }
}
