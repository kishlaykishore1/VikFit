//
//  PersionalizeVC.swift
//  VIKFIT
//

import UIKit

class PersionalizeVC: UIViewController {
    
    @IBOutlet weak var lblSubTitle: UILabel!
    var isFromSetting = false
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        setRightButton(tintColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), isImage: false, image: UIImage())
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        self.title = ""
        
        let str1 = "Answer a ".localized
        let str2 = "few questions".localized
        
        let str3 = " to generate your ".localized
        let str4 = "training program".localized
        let str5 = ".\n\nWe will never share this information.".localized
        
        let attributes1: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Medium", size: 13)!,
            .foregroundColor: UIColor.black,
        ]
        let attributes2: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-SemiBold", size: 13)!,
            .foregroundColor: UIColor.black,
        ]
        let attributedStr1 = NSAttributedString(string: str1, attributes: attributes1)
        let attributedStr2 = NSAttributedString(string: str2, attributes: attributes2)
        let attributedStr3 = NSAttributedString(string: str3, attributes: attributes1)
        let attributedStr4 = NSAttributedString(string: str4, attributes: attributes2)
        let attributedStr5 = NSAttributedString(string: str5, attributes: attributes1)
        
        let strAttrSubTitle = NSMutableAttributedString()
        strAttrSubTitle.append(attributedStr1)
        strAttrSubTitle.append(attributedStr2)
        strAttrSubTitle.append(attributedStr3)
        strAttrSubTitle.append(attributedStr4)
        strAttrSubTitle.append(attributedStr5)
        lblSubTitle.attributedText = strAttrSubTitle
    }
    
}
//MARK:- Button Actions
extension PersionalizeVC {
    //Mark:Right Button tap Action
    override func rightBtnTapAction(sender: UIButton) {
        if isFromSetting {
            self.dismiss(animated: true, completion: nil)
        } else {
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
    //Mark: Start button Tap Action
    @IBAction func actionStart(_ sender: UIButton) {
        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "GenderVC") as! GenderVC
        aboutVC.isFromSetting = isFromSetting
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
}
