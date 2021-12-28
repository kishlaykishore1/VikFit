//
//  UpdatePhoneVC.swift
//  VIKFIT
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseAuth
import ADCountryPicker

class UpdatePhoneVC: UIViewController {
    
    @IBOutlet weak var msgNo: UIButton!
    @IBOutlet weak var tfPhoneNo: UITextField!
    @IBOutlet weak var lblContryCode: UILabel!
    var settingsVC: SettingVC?
    let picker = ADCountryPicker()
    var txtCode = "+33"
    var perivousNo = ""
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        
        picker.searchBarBackgroundColor = UIColor.white
        picker.hidesNavigationBarWhenPresentingSearch = false
        picker.defaultCountryCode = "FR"
        picker.delegate = self
        hideKeyboardWhenTappedAround()
        lblContryCode.text = "\(emojiFlag(regionCode: "FR")!) +33"
        
        self.title = Messages.txtYUpdatePhoneTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 12)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1)]
    }
    override func viewDidAppear(_ animated: Bool) {
        tfPhoneNo.becomeFirstResponder()
        if perivousNo == "" {
          msgNo.setTitle("", for: .normal)
        } else {
            msgNo.setTitle("\(Messages.txtYourCurrentNo) \(perivousNo)", for: .normal)
        }
        
    }
    
    @IBAction func actionSelectCountry(_ sender: UIControl) {
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
    }
}
//MARK:- Button Actions
extension UpdatePhoneVC {
    //Mark: Back Button Action
    override func backBtnTapAction() {
        self.dismiss(animated: true, completion: nil)
    }
    //Mark: Send Code Button Action
    @IBAction func actionSendCode(_ sender: UIButton) {
        
        if !Validation.isValidMobileNumber(value: tfPhoneNo.text ?? "") {
            Common.showAlertMessage(message: Messages.validPhone, alertType: .error)
            return
        }
        apiUniquePhone(phoneNo: "\(txtCode)\(tfPhoneNo.text!)")
    }
    
    func apiUniquePhone(phoneNo: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param: [String : Any] = ["phone_number": phoneNo, "user_id": userId]
        if let getRequest = API.UNIQUEPHONE.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                
                API.UNIQUEPHONE.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        Global.dismissLoadingSpinner()
                        return
                    }
                    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNo, uiDelegate: nil) { (verificationID, error) in
                        Global.dismissLoadingSpinner()
                        if error != nil {
                            Common.showAlertMessage(message: Messages.validPhoneOrCountryCode, alertType: .error)
                            return
                        }
                        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "OTPVC") as! OTPVC
                        aboutVC.settingsVC = self.settingsVC
                        aboutVC.verificationID = verificationID ?? ""
                        aboutVC.mobileNo = "\(self.txtCode)\(self.tfPhoneNo.text!)"
                        aboutVC.isUpdate = true
                        self.navigationController?.pushViewController(aboutVC, animated: true)
                    }
                })
            }
        }
    }
}

extension UpdatePhoneVC: ADCountryPickerDelegate {
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
