//
//  TranningSessionGenrationSucessVC.swift
//  VIKFIT
//

import UIKit

class TranningSessionGenrationSucessVC: UIViewController {
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
}
//MARK:- Button Actions
extension TranningSessionGenrationSucessVC {
    //Mark: Discover Button action
    @IBAction func actionBtnDiscover(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.isUserLogin(true)
            }
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.isUserLogin(true)
        }
    }
}
