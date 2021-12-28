//
//  ProfilePictureVC.swift
//  VIKFIT
//


import UIKit

class ProfilePictureVC: UIViewController {
    
    @IBOutlet weak var ivProfile: UIImageView!
    var welcomeVC: WelcomeVC?
    var mobileNo = ""
    var param: [String: Any] = [:]
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ivProfile.image = #imageLiteral(resourceName: "avtar")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        self.title = Messages.txtProfilePictureTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 12)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1)]
        guard let url = URL(string: param["avatar"] as! String) else {
            return
        }
        ivProfile.af_setImage(withURL: url)
    }
}
//MARK:- Button Action
extension ProfilePictureVC {
    //Mark: Back Button action
    override func backBtnTapAction() {
        self.dismiss(animated: true) {
            self.welcomeVC?.openLoginOptions()
        }
    }
    //Mark: Select profile Pic Action
    @IBAction func actionSelectProfilePic(_ sender: UIView) {
        showImagePickerView()
    }
    //Mark: Next Button Action
    @IBAction func actionNext(_ sender: UIButton) {
        if ivProfile.image! == #imageLiteral(resourceName: "avtar") {
            Common.showAlertMessage(message: Messages.txtProfilePictureAlertMes, alertType: .error)
            return
        }
        param["phone_number"] = mobileNo
        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "FirstNameVC") as! FirstNameVC
        aboutVC.profilePic = ivProfile.image!
        aboutVC.param = param
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
}

//MARK: UIImagePickerController Config
extension ProfilePictureVC {
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
extension ProfilePictureVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let  pickedImage = info[.editedImage] as? UIImage {
            ivProfile.contentMode = .scaleAspectFill
            ivProfile.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
