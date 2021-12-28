//
//  LoadingVC.swift
//  VIKFIT
//

import UIKit

class LoadingVC: UIViewController {
    
    @IBOutlet weak var progressBar: LinearProgressBar!
    var isFromSetting = false
    var param: [String: Any] = [:]
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        progressBar.progressBarColor = #colorLiteral(red: 0.937254902, green: 0.8352941176, blue: 0.06274509804, alpha: 1)
        progressBar.progressBarWidth = 6
        progressBar.cornerRadius = 3
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        progressBar.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let userId = UserModel.getUserModel()?.id {
            param["user_id"] = userId
            apiUpdatePersionalization()
        } else {
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
    
    func apiUpdatePersionalization() {
        if let getRequest = API.UPDATEPERSONALIZATION.request(method: .post, with: param, forJsonEncoding: true) {
            getRequest.responseJSON { response in
                API.UPDATEPERSONALIZATION.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    UserModel.storeUserModel(value: getData)
                    if self.isFromSetting {
                        self.view.window!.rootViewController?.dismiss(animated: true, completion: {
                            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
                            if #available(iOS 13.0, *) {
                                aboutVC.isModalInPresentation = true
                            }
                            guard let getNav = UIApplication.topViewController()?.navigationController else {
                                return
                            }
                            
                            let rootNavView = UINavigationController(rootViewController: aboutVC)
                            getNav.present( rootNavView, animated: true, completion: nil)
                        })
                    } else {
                        self.dismiss(animated: true) {
                            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "TranningSessionGenrationSucessVC") as! TranningSessionGenrationSucessVC
                            guard let getNav = UIApplication.topViewController()?.navigationController else {
                                return
                            }
                            let rootNavView = UINavigationController(rootViewController: aboutVC)
                            if #available(iOS 13.0, *) {
                                aboutVC.isModalInPresentation = true
                            }
                            getNav.present( rootNavView, animated: true, completion: nil)
                            
                            
                        }
                    }
                })
                
            }
        }
    }
}
