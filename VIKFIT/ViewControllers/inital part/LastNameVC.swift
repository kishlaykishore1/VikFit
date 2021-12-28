//
//  LastNameVC.swift
//  VIKFIT
//


import UIKit

class LastNameVC: UIViewController {
    
    @IBOutlet weak var tfLastName: UITextField!
    var param: [String: Any] = [:]
    var profilePic = #imageLiteral(resourceName: "avtar")
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tfLastName.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        self.title = Messages.txtProfilePictureTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 12)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1)]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tfLastName.becomeFirstResponder()
        tfLastName.text = param["last_name"] as? String ?? ""
    }
}
//MARK:- Buttons Action
extension LastNameVC {
    //Mark: Back Button Tap Action
    override func backBtnTapAction() {
        self.navigationController?.popViewController(animated: true)
    }
    //Mark: next Button Action
    @IBAction func actionNext(_ sender: UIButton) {
        gotoNext(txt: tfLastName.text ?? "")
    }
    
    func gotoNext(txt: String) {
        if param["login_by"] as! String != "apple" {
        if Validation.isBlank(for: txt) {
            Common.showAlertMessage(message: Messages.txtLastNameAlertMes, alertType: .error)
            return
        }
        }
        param["last_name"] = txt
        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "EmailVC") as! EmailVC
        aboutVC.profilePic = profilePic
        aboutVC.param = param
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
}
//MARK:- Text field delegate Method
extension LastNameVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        gotoNext(txt: textField.text ?? "")
        return true
    }
}
