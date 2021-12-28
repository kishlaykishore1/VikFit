//
//  OtherProfileVC.swift
//  VIKFIT
//

import UIKit

class OtherProfileVC: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var profilBackView: UIView!
    @IBOutlet weak var lblTitleWithAge: UILabel!
    @IBOutlet weak var lblWeekCount: UILabel!
    @IBOutlet weak var lblWeek: UILabel!
    @IBOutlet weak var lblFolloeings: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnFolllowTitle: UIButton!
    @IBOutlet weak var lblFollowingsTxt: UILabel!
    @IBOutlet weak var lblFollowersTxt: UILabel!
    
    var otherUserData: OtherUserModal?
    var otherUserId = ""
    var previousController: UIViewController?
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
       DispatchQueue.main.async {
            self.apiOtherProfile()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        DispatchQueue.main.async {
            self.profilBackView.cornerRadius =  self.profilBackView.frame.height / 2
            self.imgProfile.cornerRadius =  self.imgProfile.frame.height / 2
            self.apiOtherProfile()
        }
        
    }
    
    @IBAction func action_Follow(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        apiFollowUser()
    }
}
//MARK:- Button Actions
extension OtherProfileVC {
    //Mark: Back Button Action
    @IBAction func actionBtnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //Mark: Report Button Action
    @IBAction func actionBtnReport(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var txtBlockProfile = Messages.txtBlockProfile
        if self.otherUserData?.isBlock ?? false {
            txtBlockProfile = Messages.txtUnBlockProfile
        }
        let reportProfile = UIAlertAction(title: Messages.txtAlertTitle, style: .default){ _ in
            //MARK: Alert Controller For Report User
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: Messages.txtAlertReportUserTitle, message: Messages.txtAlertMess, preferredStyle: .alert)
                
                let saveAction = UIAlertAction(title: Messages.txtSettingSend, style: .destructive, handler: { alert -> Void in
                    let firstTextField = alertController.textFields![0] as UITextField
                    if firstTextField.text?.trim().count == 0 {
                        Common.showAlertMessage(message: Messages.txtAlertMesReport, alertType: .error)
                        return
                    }
                    self.apiReportUser(reason: firstTextField.text!)
                })
                
                alertController.addTextField { (textField : UITextField!) -> Void in
                    saveAction.isEnabled = false
                    textField.placeholder = Messages.txtReportDetailPlaceHolder
                    textField.autocapitalizationType = .sentences
                    textField.isEnabled = false
                    
                    NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                        {_ in
                            let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                            let textIsNotEmpty = textCount > 0
                            saveAction.isEnabled = textIsNotEmpty
                    })
                }
                
                let cancelAction = UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel, handler: { (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(saveAction)
                self.present(alertController, animated: true, completion: {
                    let firstTextField = alertController.textFields![0] as UITextField
                    firstTextField.isEnabled = true
                    firstTextField.becomeFirstResponder()
                })
            }
        }
        let blockProfile = UIAlertAction(title: txtBlockProfile, style: .destructive) { _ in
            var txtBlockUser = Messages.txtBlockUserOther
            var txtBlockMessage = Messages.txtBlockUserMesOther
            if self.otherUserData?.isBlock ?? false {
                txtBlockUser = Messages.txtUnBlockUserOther
                txtBlockMessage = Messages.txtBlockUserMes
            }
            let optionMenu = UIAlertController(title: txtBlockUser, message: txtBlockMessage, preferredStyle: .alert)
            let btnBlock = UIAlertAction(title: txtBlockUser, style: .destructive) { _ in
                self.apiBlockUser()
                
            }
            let cancelAction = UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel)
            optionMenu.addAction(btnBlock)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel)
        optionMenu.addAction(reportProfile)
        optionMenu.addAction(blockProfile)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    //Mark: Followers Action
    @IBAction func actionFollowers(_ sender: UIView) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let followers = otherUserData?.followers, followers > 0 else {
            return
        }
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "FollowersFollowingVC") as! FollowersFollowingVC
        if followers > 1 {
            aboutVC.strTitle = "Followers".localized
        } else {
            aboutVC.strTitle = "Follower".localized
        }
        aboutVC.userId =  otherUserData?.id ?? ""
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    //Mark: Followings Action
    @IBAction func actionFollowings(_ sender: UIView) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let followings = otherUserData?.followings, followings > 0 else {
            return
        }
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "FollowersFollowingVC") as! FollowersFollowingVC
        if followings > 1 {
            aboutVC.strTitle = "Followings".localized
        } else {
            aboutVC.strTitle = "Following".localized
        }
        aboutVC.userId =  otherUserData?.id ?? ""
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
}

//MARK:- DataSet Profile And Api Call
extension OtherProfileVC {
    
    func profileData() {
        guard let data = otherUserData else {
            return
        }
        let fullName = "\(data.firstName) \(data.lastName)"
        lblFollowers.text = "\(data.followers)"
        lblFolloeings.text = "\(data.followings)"
        lblDescription.text = data.bio
        lblWeekCount.text = data.plans
        if data.isFollow {
            btnFolllowTitle.setTitle("\(Messages.txtUnfollowUser) \(data.firstName)", for: .normal)
        } else {
            btnFolllowTitle.setTitle("\(Messages.txtfollowUser) \(data.firstName)", for: .normal)
        }
        
        if  data.followings > 1 {
            lblFollowingsTxt.text = "Followings".localized
        } else {
            lblFollowingsTxt.text = "Following".localized
        }
        if  data.followers > 1 {
            lblFollowersTxt.text = "Followers".localized
        } else {
            lblFollowersTxt.text = "Follower".localized
        }
        
        if (Int(data.plans) ?? 0) > 1 {
            lblWeek.text = "Weeks".localized
        } else {
            lblWeek.text = "Week".localized
        }
        
        if let url = URL(string: data.profilePic) {
            imgProfile.af_setImage(withURL: url)
            imgProfile.contentMode = .scaleAspectFill
        }
        
        if data.age > 0 {
            
            let attributedName = NSAttributedString(string: "\(fullName), ", attributes:  [NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 20)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.262745098, alpha: 1)] as [NSAttributedString.Key : Any])
            let attributedAge = NSAttributedString(string: "\(data.age)", attributes:  [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 20)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)] as [NSAttributedString.Key : Any])
            let txt = NSMutableAttributedString()
            txt.append(attributedName)
            txt.append(attributedAge)
            lblTitleWithAge.attributedText = txt
        } else {
            let attributedName = NSAttributedString(string: "\(fullName)", attributes:  [NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 20)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.262745098, alpha: 1)] as [NSAttributedString.Key : Any])
            let txt = NSMutableAttributedString()
            txt.append(attributedName)
            lblTitleWithAge.attributedText = txt
        }
        
    }
    
    //MARK:- Api Profile
    func apiOtherProfile() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["other_user_id": otherUserId, "user_id": userId]
        if let getRequest = API.OTHERUSERPROFILE.request(method: .post, with: param, forJsonEncoding: true) {
            //DispatchQueue.main.async {
            Global.dismissLoadingSpinner()
            Global.showLoadingSpinner()
            // }
            
            getRequest.responseJSON { response in
                //DispatchQueue.main.async {
                Global.dismissLoadingSpinner()
                // }
                API.OTHERUSERPROFILE.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        do {
                            let decoder = JSONDecoder()
                            self.otherUserData = try decoder.decode(OtherUserModal.self, from: jsonData)
                            self.profileData()
                        } catch let err {
                            print("Err", err)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                })
            }
        }
    }
    //MARK:- Api Profile
    func apiBlockUser() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["block_user_id": otherUserId, "user_id": userId]
        if let getRequest = API.BLOCKUSER.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.BLOCKUSER.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                    self.apiOtherProfile()
                    self.dismiss(animated: true) {
                        self.previousController?.viewWillAppear(true)
                    }
                    
                })
            }
        }
    }
    
    func apiReportUser(reason: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "report_user_id": otherUserId, "reason": reason]
        if let getRequest = API.USERREPORT.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.USERREPORT.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: Messages.txtCofirmMesText, alertType: .success)
                    self.apiOtherProfile()
                })
            }
        }
    }
    
    func apiFollowUser() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["follow_user_id": otherUserId, "user_id": userId]
        if let getRequest = API.FOLLOW.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.FOLLOW.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    if jsonObject?["message"] as? String != "" {
                        Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                    }
                    self.apiOtherProfile()
                })
            }
        }
    }
}
