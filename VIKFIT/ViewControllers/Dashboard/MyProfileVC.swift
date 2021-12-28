//
//  MyProfileVC.swift
//  VIKFIT
//


import UIKit
import AlamofireImage

class MyProfileVC: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var profilBackView: UIView!
    @IBOutlet weak var lblTitleWithAge: UILabel!
    @IBOutlet weak var lblWeekCount: UILabel!
    @IBOutlet weak var lblWeeks: UILabel!
    @IBOutlet weak var lblFollowings: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var imgBlueTik: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblFollowingsTxt: UILabel!
    @IBOutlet weak var lblFollowersTxt: UILabel!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileData()
        apiMyprofile()
    }
    override func viewWillAppear(_ animated: Bool) {
        apiMyprofile()
    }
    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async {
            self.profilBackView.cornerRadius =  self.profilBackView.frame.height / 2
            self.imgProfile.cornerRadius =  self.imgProfile.frame.height / 2
        }
    }
    @IBAction func actionEditProfile(_ sender: UIButton) {
        showImagePickerView()
    }
}
//MARK:- Buttons Action
extension MyProfileVC {
    //Mark: EditProfile Button Action
    @IBAction func actionBtnEditProfile(_ sender: Any) {
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        aboutVC.myProfileVC = self
        if #available(iOS 13.0, *) {
            aboutVC.isModalInPresentation = true
        }
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    //Mark: Followers Button Action
    @IBAction func actionFollowers(_ sender: UIView) {
        guard let followers = UserModel.getUserModel()?.followers, followers > 0 else {
            return
        }
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "FollowersFollowingVC") as! FollowersFollowingVC
        if followers > 1 {
            aboutVC.strTitle = "Followers".localized
        } else {
            aboutVC.strTitle = "Follower".localized
        }
        aboutVC.userId =  userId
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    
    //Mark: Following Button Action
    @IBAction func actionFollowings(_ sender: UIView) {
        guard let followings = UserModel.getUserModel()?.followings, followings > 0 else {
            return
        }
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "FollowersFollowingVC") as! FollowersFollowingVC
        if followings > 1 {
            aboutVC.strTitle = "Followings".localized
        } else {
            aboutVC.strTitle = "Following".localized
        }
        aboutVC.userId =  userId
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
}

//MARK:- DataSet Profile And Api Call
extension MyProfileVC {
    
    func profileData() {
        guard let data = UserModel.getUserModel() else {
            return
        }
        let fullName = "\(data.firstName) \(data.lastName)"
        lblFollowers.text = "\(data.followers)"
        lblFollowings.text = "\(data.followings)"
        imgBlueTik.isHidden = !data.verified
        lblDescription.text = data.bio
        lblWeekCount.text = data.plans
        
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
             lblWeeks.text = "Weeks".localized
         } else {
             lblWeeks.text = "Week".localized
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
    func apiMyprofile() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId]
        if let getRequest = API.PROFILE.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { response in
                Global.dismissLoadingSpinner()
                API.LOGINGOOGLE.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    print(getData)
                    UserModel.storeUserModel(value: getData)
                    self.profileData()
                })
            }
        }
    }
    
    
    func apiUploadPic(image: UIImage) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId]
        Global.showLoadingSpinner()
        API.UPDATEPROFILEPIC.requestUpload(with: param, files: ["image": image]) { (response, error) in
            Global.dismissLoadingSpinner()
            guard error == nil, let getData = response?["data"] as? [String: Any] else {
                return
            }
            UserModel.storeUserModel(value: getData)
            self.profileData()
        }
    }
}

//MARK: UIImagePickerController Config
extension MyProfileVC {
    func openCamera() {
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            Common.showAlertMessage(message: Messages.cameraNotFound, alertType: .warning)
        }
    }
    
    func openGallary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func showImagePickerView() {
        let alert = UIAlertController(title: Messages.photoMassage, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title:  Messages.txtCamera, style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: Messages.txtGallery, style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: UIImagePickerControllerDelegate
extension MyProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let  pickedImage = info[.editedImage] as? UIImage {
            guard (UserModel.getUserModel()?.id) != nil else {return}
            imgProfile.contentMode = .scaleAspectFill
            imgProfile.image = pickedImage
            apiUploadPic(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
