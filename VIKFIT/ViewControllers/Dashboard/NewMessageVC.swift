//
//  NewMessageVC.swift
//  VIKFIT
//

import UIKit

class NewMessageVC: UIViewController {
    
    @IBOutlet weak var tfWriteSmoething: UITextView!
    @IBOutlet weak var btnAddPhoto: UIView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTermsNService: TTTAttributedLabel!
    
    var arrImages = [#imageLiteral(resourceName: "camera_yellow"),#imageLiteral(resourceName: "camera_yellow"),#imageLiteral(resourceName: "camera_yellow"),#imageLiteral(resourceName: "camera_yellow"),#imageLiteral(resourceName: "camera_yellow"),#imageLiteral(resourceName: "camera_yellow")]
    var selectedIndex = 0
    var editPost = false
    var perivousText = ""
    var newsFeedsVC: NewsFeedsVC?
    var postID = ""
    var commentVC: CommentVC?
    var images = [String]()
    var previousIndex = 0
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if arrImages[selectedIndex] == #imageLiteral(resourceName: "camera_yellow") {
            collectionViewHeight.constant = 0.0
            collectionView.isHidden = true
            btnAddPhoto.isHidden = false
        } else {
            collectionViewHeight.constant = 160
            collectionView.isHidden = false
            btnAddPhoto.isHidden = true
        }
        
        for (index, image) in images.enumerated() {
            guard let url = URL(string: image) else {
                return
            }
            Global.showLoadingSpinner()
            DispatchQueue.global().async {
                // Fetch Image Data
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        Global.dismissLoadingSpinner()
                        // Create Image and Update Image View
                        self.arrImages[index] = UIImage(data: data)!
                        if self.arrImages[self.selectedIndex] == #imageLiteral(resourceName: "camera_yellow") {
                            self.collectionViewHeight.constant = 0.0
                            self.collectionView.isHidden = true
                            self.btnAddPhoto.isHidden = false
                        } else {
                            self.collectionViewHeight.constant = 160
                            self.collectionView.isHidden = false
                            self.btnAddPhoto.isHidden = true
                        }
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
        tfWriteSmoething.text = Messages.txtTextViewNewsFeed
        tfWriteSmoething.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        if !perivousText.isEmpty {
            tfWriteSmoething.text = perivousText
            tfWriteSmoething.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideKeyboardWhenTappedAround()
        self.navigationController?.isNavigationBarHidden = false
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        setBackButton(tintColor: #colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1), isImage: true)
        if editPost {
            self.title = Messages.txtTitleEditFeed
        } else {
            self.title = Messages.txtTitleNewsFeed
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 17)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tfWriteSmoething.becomeFirstResponder()
    }
    
    //Mark: Action For Add Image Button
    @IBAction func actionBtnAddPhoto(_ sender: UIControl) {
        selectedIndex = 0
        showImagePickerView()
    }
}
//MARK:- Buttons Action
extension NewMessageVC {
    //Mark:- Action For Publish Message Button
    @IBAction func actionPublishMessage(_ sender: UIButton) {
        var txt = ""
        if tfWriteSmoething.text != "Write something ..." {
            txt = tfWriteSmoething.text
        }
        if editPost {
            apiEditFeed(message: txt)
        } else {
            apiAddFeed(message: txt)
        }
    }
    //Mark: Action For Remove Image Button
    @IBAction func actionBtnRemoveImg(_ sender: UIButton) {
        arrImages[sender.tag] = #imageLiteral(resourceName: "camera_yellow")
        collectionView.reloadData()
        var isEmpty = true
        for item in arrImages {
            if item != #imageLiteral(resourceName: "camera_yellow") {
                isEmpty = false
            }
        }
        if isEmpty {
            collectionViewHeight.constant = 0.0
            collectionView.isHidden = true
            btnAddPhoto.isHidden = false
        }
    }
    
    //Mark: Back Button Pressed
    override func backBtnTapAction() {
        if editPost {
            self.dismiss(animated: true, completion: nil)
        } else {
            let optionMenu = UIAlertController(title: Messages.txtCancelPublication, message: Messages.txtCancelPublicationMes, preferredStyle: .actionSheet)
            let allUsers = UIAlertAction(title: Messages.txtCancelThePublication, style: .destructive){ _ in
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel)
            optionMenu.addAction(allUsers)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
}
//MARK:-CollectionView DataSource Methods
extension NewMessageVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMessagesCollectionCell", for: indexPath) as! NewMessagesCollectionCell
        cell.btnRemoveImg.tag = indexPath.row
        cell.imageView.image = arrImages[indexPath.row]
        if arrImages[indexPath.row] == #imageLiteral(resourceName: "camera_yellow") {
            cell.btnRemoveImg.isHidden = true
            cell.imageView.contentMode = .center
            cell.borderView._border.strokeColor = #colorLiteral(red: 0.5058823529, green: 0.462745098, blue: 0.1411764706, alpha: 1)
        } else {
            cell.btnRemoveImg.isHidden = false
            cell.imageView.contentMode = .scaleAspectFill
            cell.borderView._border.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        }
        return cell
    }
}
//MARK:-CollectionView DelegateFlowLayout Methods
extension NewMessageVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        
    }
}
//MARK:-CollectionView Delegate Methods
extension NewMessageVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        showImagePickerView()
    }
}

//MARK: UIImagePickerController Config
extension NewMessageVC {
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
extension NewMessageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let  pickedImage = info[.editedImage] as? UIImage {
            arrImages[selectedIndex] = pickedImage
            collectionViewHeight.constant = 160
            collectionView.isHidden = false
            btnAddPhoto.isHidden = true
            collectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK:-Text View Place Holder Setup functions
extension NewMessageVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if  textView.text == Messages.txtTextViewNewsFeed {
            textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Messages.txtTextViewNewsFeed
            textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        if updatedText.isEmpty {
            textView.text = Messages.txtTextViewNewsFeed
            textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6) && !text.isEmpty {
            textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            textView.text = ""
            tfWriteSmoething.text = textView.text
            return true
        } else {
            tfWriteSmoething.text = textView.text
            return true
        }
        return false
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let currentText:String = textView.text
//        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
//        if updatedText.isEmpty {
//
//            textView.text = Messages.txtTextViewNewsFeed
//            textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
//
//            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//        } else if textView.textColor == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6) && !text.isEmpty {
//            textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//            textView.text = text
//        } else {
//            return true
//        }
//        return false
//    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6) {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}
//MARK:-CollectionView Cell Class
class NewMessagesCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnRemoveImg: UIButton!
    @IBOutlet weak var borderView: DashedBorderView!
}

//MARK: TermsOfUse Label Set
extension NewMessageVC {
    func setup() {
        lblTermsNService.numberOfLines = 0;
        
        let strPP = Messages.txtPPNewsFeed
        let strTC = Messages.txtTCNewsFeed
        let string = "\(Messages.txtPpTcMesNewsFeed) \(strPP) \(Messages.txtPpTcMesNewsFeed1) \(strTC)."
        
        let nsString = string as NSString
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        
        let fullAttributedString = NSAttributedString(string:string, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5294117647, green: 0.5294117647, blue: 0.5294117647, alpha: 1),
            NSAttributedString.Key.font: UIFont.init(name: "Poppins-Medium", size: 11) ?? UIFont()
        ])
        
        lblTermsNService.textAlignment = .center
        lblTermsNService.attributedText = fullAttributedString
        
        let rangeTC = nsString.range(of: strTC)
        let rangePP = nsString.range(of: strPP)
        
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: #colorLiteral(red: 0.5294117647, green: 0.5294117647, blue: 0.5294117647, alpha: 1),
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue: UIFont.init(name: "Poppins-SemiBold", size: 11) ?? UIFont()
        ]
        
        lblTermsNService.activeLinkAttributes = ppLinkAttributes
        lblTermsNService.linkAttributes = ppLinkAttributes
        
        let urlTC = URL(string: "action://TC")!
        let urlPP = URL(string: "action://PP")!
        lblTermsNService.addLink(to: urlTC, with: rangeTC)
        lblTermsNService.addLink(to: urlPP, with: rangePP)
        
        lblTermsNService.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lblTermsNService.delegate = self
    }
}

//MARK: TTTAttributedLabelDelegate
extension NewMessageVC: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        if url.absoluteString == "action://TC" {
            
            let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.titleString = Messages.txtSec5TermService
            webViewController.url = Constants.kAppDelegate.generalSettingsModal?.terms ?? ""
            navigationController?.pushViewController(webViewController, animated: true)
            
            //            guard let url = URL(string: Constants.kAppDelegate.generalSettingsModal?.terms ?? "") else { return }
            //            UIApplication.shared.open(url)
        } else {
            
            let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.titleString = Messages.txtSec5PrivacyPolicy
            webViewController.url = Constants.kAppDelegate.generalSettingsModal?.privacy ?? ""
            navigationController?.pushViewController(webViewController, animated: true)
            
            //            guard let url = URL(string: Constants.kAppDelegate.generalSettingsModal?.privacy ?? "") else { return }
            //            UIApplication.shared.open(url)
        }
        
    }
}

extension NewMessageVC {
    func apiAddFeed(message: String) {
        var imgParam: [String: UIImage] = [:]
        var i = 0
        for (_, image) in arrImages.enumerated() {
            if image != #imageLiteral(resourceName: "camera_yellow") {
                imgParam["uploadFile[\(i)]"] = image
                i += 1
            }
        }
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        if message == "" {
            Common.showAlertMessage(message: Messages.txtTextViewNewsFeed, alertType: .error)
            return
        }
        
        let param:[String: Any] = ["user_id": userId, "description": message]
        Global.showLoadingSpinner()
        API.ADDFEED.requestUpload(with: param, files: imgParam) { (response, error) in
            Global.dismissLoadingSpinner()
            guard error == nil else {
                return
            }
            self.dismiss(animated: true) {
                self.newsFeedsVC?.apiGetFeeds(false, pageNo: 1)
            }
        }
    }
    func apiEditFeed(message: String) {
        
        var imgParam: [String: UIImage] = [:]
        var i = 0
        for (_, image) in arrImages.enumerated() {
            if image != #imageLiteral(resourceName: "camera_yellow") {
                imgParam["uploadFile[\(i)]"] = image
                i += 1
            }
        }
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        
        if message == "" {
            Common.showAlertMessage(message: Messages.txtTextViewNewsFeed, alertType: .error)
            return
        }
        
        let param:[String: Any] = ["user_id": userId, "description": message, "post_id": postID]
        Global.showLoadingSpinner()
        API.UPDATEFEED.requestUpload(with: param, files: imgParam) { (response, error) in
            Global.dismissLoadingSpinner()
            guard error == nil else {
                return
            }
            self.newsFeedsVC?.apiGetFeeds(false, pageNo: 1)
            self.commentVC?.apiGetFeed(false)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
