//
//  AppDelegate.swift
//  VIKFIT
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import CoreLocation
import FBSDKCoreKit
import GoogleSignIn
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var window: UIWindow?
    var kApplication: UIApplication?
    var generalSettingsModal: GeneralSettingsModal?
    var lat = ""
    var long = ""
    var appSharedSecrateKey = "8f00663a565a4da8a7e848362a2d9ddf"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //        IAPManager.shared.startObserving()
        UserDefaults.standard.set(true, forKey: "isAdvt")
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done".localized
        IQKeyboardManager.shared.enableAutoToolbar = false
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        kApplication = application
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 5
        }
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        apiGeneralSetting()
        if UserModel.getUserModel() != nil {
            self.isUserLogin(true)
        } else {
            self.isUserLogin(false)
        }
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        lat = "\(locValue.latitude)"
        long = "\(locValue.longitude)"
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(false, forKey: "isAdvt")
        IAPManager.shared.stopObserving()
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance().handle(url)
        let sourceApplication: String? = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: sourceApplication, annotation: nil)
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //MARK:- for APNS token
        let hexString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(hexString, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
        print(hexString)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo as? [String: Any]
        guard  let dataResponse = userInfo!["aps"] as? [String: Any],  let dataNotification = dataResponse["alert"] as? [String: Any] else {
            return
        }
        print(dataNotification["type"] as! String)
        actionOnTapNotification(dataNotification)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard  let dataResponse = userInfo["aps"] as? [String: Any],  let dataNotification = dataResponse["alert"] as? [String: Any] else {
            return
        }
        print(dataNotification["type"] as! String)
        actionOnTapNotification(dataNotification)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    fileprivate func actionOnTapNotification(_ dataNotification: [String : Any]) {
        switch dataNotification["type"] as! String {
        case "profile":
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
            aboutVC.otherUserId = dataNotification["user_id"] as! String
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        case "post_view":
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            aboutVC.postId = dataNotification["post_id"] as! String
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        case "home":
            break
        case "payment":
            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
            aboutVC.isFromHome = true
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            rootNavView.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                getNav.isModalInPresentation = true
            }
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        case "url":
            if let url = URL(string: dataNotification["link"] as! String) {
                UIApplication.shared.open(url)
            }
            break
        case "article":
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "BlogArticalsVC") as! BlogArticalsVC
            aboutVC.blogId = dataNotification["post_id"] as! String
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        case "exercise":
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "ExerciseVC") as! ExerciseVC
            aboutVC.exerciseID = dataNotification["post_id"] as! String
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            rootNavView.modalPresentationStyle = .fullScreen
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        default:
            break
        }
    }
}

extension AppDelegate {
    //Check User Login
    func isUserLogin(_ isLogin: Bool) {
        if isLogin {
            let homeTabBar = StoryBoard.Home.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            let nav = UINavigationController(rootViewController: homeTabBar)
            nav.isNavigationBarHidden = true
            window?.rootViewController = nav
            window?.makeKeyAndVisible()
        } else {
            let welcomeVC = StoryBoard.Main.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            self.window?.rootViewController = UINavigationController(rootViewController: welcomeVC)
            self.window?.makeKeyAndVisible()
        }
    }
}

//MARK: API Call
extension AppDelegate {
    func apiGeneralSetting() {
        if let getRequest = API.GENERALSETTING.request(method: .post, with: [:], forJsonEncoding: true) {
            getRequest.responseJSON { (response) in
                API.GENERALSETTING.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.generalSettingsModal = try decoder.decode(GeneralSettingsModal.self, from: jsonData)
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
}
