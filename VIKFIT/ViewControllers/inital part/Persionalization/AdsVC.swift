//
//  AdsVC.swift
//  VIKFIT
//


import UIKit

class AdsVC: UIViewController {
    //MARK:Life Cycle
    @IBOutlet weak var imgAdd: UIImageView!
    var sponserUrl = ""
    var fromHome = false
    override func viewDidLoad() {
        super.viewDidLoad()
        apiGetAd()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        setRightButton(tintColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), isImage: false, image: UIImage())
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        self.title = Messages.txtAdVCtitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 18)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)]
    }
    override func viewDidDisappear(_ animated: Bool) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error != nil {}
            self.updateToken(deviceToken: UserDefaults.standard.string(forKey: "deviceToken") ?? "5ed812dbccb12ea9a7a98fae0527c9642efb581a11bb54995f9b8fa022e8aef4", lat: Constants.kAppDelegate.lat, long: Constants.kAppDelegate.long)
        }
        Constants.kAppDelegate.kApplication?.registerForRemoteNotifications()
    }
}
//MARK:- Button Actions
extension AdsVC {
    //Mark: Right Button Tap Action
    override func rightBtnTapAction(sender: UIButton) {
        if fromHome {
            self.dismiss(animated: true, completion: nil)
        } else {
            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PersionalizeVC") as! PersionalizeVC
            if #available(iOS 13.0, *) {
                aboutVC.isModalInPresentation = true
            }
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
        }
    }
    //Mark: Right Button Tap Action
    @IBAction func actionSponsored(_ sender: UIButton) {
        guard let url = URL(string: sponserUrl) else {return}
        UIApplication.shared.open(url)
    }
    
    func apiGetAd() {
        if let getRequest = API.GETAD.request(method: .get, with: nil, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.GETAD.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    self.sponserUrl = getData["url"] as? String ?? ""
                    guard let url = URL(string: getData["image"] as? String ?? "") else {
                        return
                    }
                    self.imgAdd.af_setImage(withURL: url)
                })
            }
        }
    }
    func updateToken(deviceToken: String, lat: String, long: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = [ "user_id": userId, "device_token": deviceToken, "latitude": lat, "longitude": long]
        if let getRequest = API.UPDATETOKEN.request(method: .post, with: param, forJsonEncoding: true) {
            getRequest.responseJSON { (response) in
                API.UPDATETOKEN.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let isLogged = jsonObject?["is_logged"] as? Bool else {
                        return
                    }
                    if !isLogged {
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
                })
            }
        }
    }
}
