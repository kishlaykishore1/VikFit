//
//  CommentVC.swift
//  VIKFIT
//

import UIKit
import IQKeyboardManagerSwift

class CommentVC: UIViewController {
    
    @IBOutlet weak var tfComment: UITextField!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iVFeed: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var ivUserProfile: UIImageView!
    @IBOutlet weak var ivVerified: UIImageView!
    @IBOutlet weak var lblFeedTime: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var btnSupport: UIButton!
    var dataSource: FeedDetailModal?
    var previousIndex = 0
    var images = [String]()
    private let refreshControl = UIRefreshControl()
    var postId = ""
    var newsFeedVC: NewsFeedsVC?
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addPullToRefresh()
        heightConstraint.constant = 0
    }
    
    @IBAction func actionFeedProfile(_ sender: UIControl) {
        guard let userId = UserModel.getUserModel()?.id, userId != dataSource?.userID ?? "" else {
            return
        }
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
        aboutVC.otherUserId = dataSource?.userID ?? ""
        aboutVC.previousController = self
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    @IBAction func actionZoomView(_ sender: UIControl) {
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "GalleryImageVC") as! GalleryImageVC
        aboutVC.imgStr  = dataSource?.image ?? ""
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.isHidden = true
        apiGetFeed(false)
        //hideKeyboardWhenTappedAround()
        self.navigationController?.isNavigationBarHidden = false
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.9790229201, green: 0.9126065373, blue: 0.1330371797, alpha: 1)
        setBackButton(tintColor: #colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1), isImage: true)
        self.title = Messages.txtTitleComment
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 17)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)]
    }
    
    @IBAction func actionSend(_ sender: UIButton) {
        self.view.endEditing(true)
        if Validation.isBlank(for: tfComment.text) {
            return
        }
        apiAddComment(tfComment.text!)
    }
}
//MARK:- Button Action
extension CommentVC {
    //Mark:Button More Action
    @IBAction func actionMore(_ sender: UIButton) {
        
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        if String(userId) == dataSource?.userID {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let edit = UIAlertAction(title: "Edit".localized, style: .default){ _ in
                let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "NewMessageVC") as! NewMessageVC
                aboutVC.perivousText = self.dataSource?.feedMessage ?? ""
                aboutVC.editPost = true
                aboutVC.postID = self.dataSource?.id ?? ""
                aboutVC.images = self.images
                aboutVC.newsFeedsVC = self.newsFeedVC
                aboutVC.commentVC = self
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
                
            }
            
            let delete = UIAlertAction(title: Messages.txtDeleteTitleNewsFeed, style: .destructive){ _ in
                
                
                let alert  = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.txtDeletePost, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    self.apiDeletePost()
                }))
                alert.addAction(UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            let cancelAction = UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel)
            optionMenu.addAction(edit)
            optionMenu.addAction(delete)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            
            let optionMenu = UIAlertController(title: Messages.txtReportPubTitleNewsFeed, message: Messages.txtCommentMes, preferredStyle: .actionSheet)
            let allUsers = UIAlertAction(title: Messages.txtReportPubTitleNewsFeed, style: .destructive){ _ in
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: Messages.txtReportThePubTitleNewsFeed, message: Messages.txtIndicateMesNewsFeed , preferredStyle: .alert)
                    
                    let saveAction = UIAlertAction(title: Messages.txtSettingSend, style: .destructive, handler: { alert -> Void in
                        let firstTextField = alertController.textFields![0] as UITextField
                        if firstTextField.text?.trim().count == 0 {
                            Common.showAlertMessage(message: Messages.txtreportDetailMesNewsFeed, alertType: .error)
                            return
                        }
                        self.apiReportOnPost(reason: firstTextField.text!)
                    })
                    alertController.addTextField { (textField : UITextField!) -> Void in
                        saveAction.isEnabled = false
                        textField.placeholder = Messages.txtTextFieldNewsFeed
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
            let cancelAction = UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel)
            optionMenu.addAction(allUsers)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
            
        }
    }
    
    //Mark:Action To zoom Image In Chat
    @IBAction func actionOpenZoomInChat(_ sender: UIView) {
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "GalleryImageVC") as! GalleryImageVC
        //  aboutVC.imgStr  = #imageLiteral(resourceName: "comment_bitmap")
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    
    //Mark:Action To zoom Image
    @IBAction func actionOpenZoom(_ sender: UIView) {
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "GalleryImageVC") as! GalleryImageVC
        aboutVC.imgStr  = dataSource?.comments[sender.tag].image ?? ""
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    
    //Mark:Action To Open Profile
    @IBAction func actionOpenProfile(_ sender: UIControl) {
        guard let userId = UserModel.getUserModel()?.id, userId != dataSource?.comments[sender.tag].userID ?? "" else {
            return
        }
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
        aboutVC.otherUserId = dataSource?.comments[sender.tag].userID ?? ""
        aboutVC.previousController = self
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    
    //Mark:Action For Image Picker
    @IBAction func actionSelectPic(_ sender: UIButton) {
        showImagePickerView()
    }
    
    //Mark:Action For Support Button
    @IBAction func actionBtnSupport(_ sender: UIButton) {
        apiLikeUnlike()
    }
    
    //Mark:Function For Removing Empty View
    @IBAction func showTable(_ sender: UIView) {
    }
    
    //Mark:Back button tap Action
    override func backBtnTapAction() {
        self.dismiss(animated: true) {
            Global.dismissLoadingSpinner()
        }
    }
}
//MARK:- Pull to refresh
extension CommentVC {
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        apiGetFeed(true)
    }
}
//MARK:-TableView DataSource Methods
extension CommentVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.comments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource?.comments[indexPath.row]
        if data?.image == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableCellText", for: indexPath) as! CommentTableCellText
            cell.profileView.tag = indexPath.row
            cell.lblMessage.text = data?.comment
            cell.lblNameUserComment.text = data?.firstName ?? ""
            cell.lblCommentTime.text = "· \(data?.createdAt ?? "")"
            if data?.verified ?? false {
                cell.ivBlue.isHidden = false
                cell.widthBlue.constant = 8
                cell.leftMargin.constant = 4
            } else {
                cell.ivBlue.isHidden = true
                cell.widthBlue.constant = 0
                cell.leftMargin.constant = 0
            }
            if let url = URL(string: data?.profilePic ?? "") {
                cell.ivUserComment.af_setImage(withURL: url)
                cell.ivUserComment.contentMode = .scaleAspectFill
            } else {
                cell.ivUserComment.image = #imageLiteral(resourceName: "feeds_user_placeholder")
                cell.ivUserComment.contentMode = .scaleAspectFit
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableCellImage", for: indexPath) as! CommentTableCellImage
            cell.profileView.tag = indexPath.row
            cell.azoomImgView.tag = indexPath.row
            cell.lblNameUserComment.text = data?.firstName ?? ""
            cell.lblCommentTime.text = "· \(data?.createdAt ?? "")"
            if let url = URL(string: data?.profilePic ?? "") {
                cell.ivUserComment.af_setImage(withURL: url)
                cell.ivUserComment.contentMode = .scaleAspectFill
            } else {
                cell.ivUserComment.image = #imageLiteral(resourceName: "feeds_user_placeholder")
                cell.ivUserComment.contentMode = .scaleAspectFit
            }
            if let url = URL(string: data?.image ?? "") {
                cell.ivComment.af_setImage(withURL: url)
                cell.ivComment.contentMode = .scaleAspectFill
            } else {
                cell.ivComment.image = UIImage()
                cell.ivComment.contentMode = .scaleAspectFit
            }
            
            if data?.verified ?? false {
                cell.ivBlue.isHidden = false
                cell.widthBlue.constant = 8
                cell.leftMargin.constant = 4
            } else {
                cell.ivBlue.isHidden = true
                cell.widthBlue.constant = 0
                cell.leftMargin.constant = 0
            }
            
            return cell
        }
    }
}
//MARK:-TableView Delegate Methods
extension CommentVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
//MARK:-Send Button Change Image Change Action If No Text Is There
extension CommentVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let preText = textField.text as NSString?, preText.replacingCharacters(in: range, with: string).count > 0 else {
            btnSend.setImage(#imageLiteral(resourceName: "right-arrow"), for: .normal)
            return true
        }
        btnSend.setImage(#imageLiteral(resourceName: "right-arrow_yellow"), for: .normal)
        return true
    }
}
//MARK: UIImagePickerController Config
extension CommentVC {
    func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
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
extension CommentVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            apiAddImgComment(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CommentVC {
    func apiGetFeed(_ isRefresh: Bool) {
        guard let userId = UserModel.getUserModel()?.id else {
            if isRefresh {
                self.refreshControl.endRefreshing()
            }
            return
        }
        let param:[String: Any] = ["user_id": userId, "post_id": postId]
        if let getRequest = API.GETFEEDDETAIL.request(method: .post, with: param, forJsonEncoding: true) {
            if !isRefresh {
                Global.showLoadingSpinner()
            }
            getRequest.responseJSON { (response) in
                if !isRefresh {
                    Global.dismissLoadingSpinner()
                }
                API.GETFEEDDETAIL.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        self.dataSource?.comments.removeAll()
                        self.emptyView.isHidden = false
                        self.tableView.reloadData()
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.dataSource = try decoder.decode(FeedDetailModal.self, from: jsonData)
                        if isRefresh {
                            self.refreshControl.endRefreshing()
                        }
                        self.setData()
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
    
    func apiAddImgComment(image: UIImage) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["post_id": postId, "user_id": userId, "comment": ""]
        Global.showLoadingSpinner()
        API.SENDCOMMENT.requestUpload(with: param, files: ["image": image]) { (response, error) in
            Global.dismissLoadingSpinner()
            guard error == nil else {
                return
            }
            self.apiGetFeed(false)
            self.newsFeedVC?.apiGetFeeds(false, pageNo: 1)
        }
    }
    
    func apiAddComment( _ comment: String = "") {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["post_id": postId, "user_id": userId, "comment": comment]
        if let getRequest = API.SENDCOMMENT.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.SENDCOMMENT.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.tfComment.text = ""
                    self.apiGetFeed(false)
                    self.newsFeedVC?.dataSource[self.previousIndex].userComment = true
                    self.newsFeedVC?.dataSource[self.previousIndex].comments = (self.newsFeedVC?.dataSource[self.previousIndex].comments ?? 0) + 1
                    self.newsFeedVC?.tableView.reloadData()
                })
            }
        }
    }
    
    func apiLikeUnlike() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "post_id": postId]
        
        if let getRequest = API.LIKEPOST.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.LIKEPOST.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.dataSource!.userLike = !self.dataSource!.userLike
                    self.apiGetFeed(false)
                    self.newsFeedVC?.dataSource[self.previousIndex].userLike = !(self.newsFeedVC?.dataSource[self.previousIndex].userLike ?? false)
                    if self.newsFeedVC?.dataSource[self.previousIndex].userLike ?? false {
                        self.newsFeedVC?.dataSource[self.previousIndex].likes = (self.newsFeedVC?.dataSource[self.previousIndex].likes ?? 0) + 1
                    } else {
                        self.newsFeedVC?.dataSource[self.previousIndex].likes = (self.newsFeedVC?.dataSource[self.previousIndex].likes ?? 0) - 1
                    }
                    self.newsFeedVC?.tableView.reloadData()
                })
            }
        }
    }
    
    func apiReportOnPost(reason: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "post_id": postId, "reason": reason]
        
        if let getRequest = API.REPORTONFEED.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.REPORTONFEED.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: Messages.txtReportOnPostMes, alertType: .success)
                })
            }
        }
    }
    
    func apiDeletePost() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "post_id": postId]
        
        if let getRequest = API.DELETEPOST.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.DELETEPOST.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                    self.dismiss(animated: true) {
                        self.newsFeedVC?.dataSource.remove(at: self.previousIndex)
                        self.newsFeedVC?.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func setData() {
        
        lblDescription.text = dataSource?.feedMessage ?? ""
        
        if (dataSource?.likeTotal ?? 0) > 1 {
            btnSupport.setTitle("\(Messages.txtSupports) (\(dataSource?.likeTotal ?? 0))", for: .normal)
        } else {
            btnSupport.setTitle("\(Messages.txtSupport) (\(dataSource?.likeTotal ?? 0))", for: .normal)
        }
        if (dataSource?.commentTotal ?? 0) > 1 {
            btnComment.setTitle("\(Messages.txtComments) (\(dataSource?.commentTotal ?? 0))", for: .normal)
        } else {
            btnComment.setTitle("\(Messages.txtComment) (\(dataSource?.commentTotal ?? 0))", for: .normal)
        }
        ivVerified.isHidden = !(dataSource?.verified ?? false)
        lblFeedTime.text = dataSource?.createdAt ?? ""
        lblUserName.text = dataSource?.firstName ?? ""
        
        if dataSource?.userLike ?? false {
            btnSupport.setImage(#imageLiteral(resourceName: "clapping copy"), for: .normal)
            btnSupport.setTitleColor(#colorLiteral(red: 0, green: 1, blue: 0.7764705882, alpha: 1), for: .normal)
            
        } else {
            btnSupport.setImage(#imageLiteral(resourceName: "feed_support"), for: .normal)
            btnSupport.setTitleColor(#colorLiteral(red: 0.6901960784, green: 0.6901960784, blue: 0.6901960784, alpha: 1), for: .normal)
        }
        if dataSource?.userComment ?? false {
            btnComment.setImage(#imageLiteral(resourceName: "feed_comment"), for: .normal)
            btnComment.imageView?.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.5019607843, alpha: 1)
            btnComment.setTitleColor(#colorLiteral(red: 1, green: 0, blue: 0.5019607843, alpha: 1), for: .normal)
        } else {
            btnComment.setImage(#imageLiteral(resourceName: "feed_comment"), for: .normal)
            btnComment.imageView?.tintColor = #colorLiteral(red: 0.6901960784, green: 0.6901960784, blue: 0.6901960784, alpha: 1)
            btnComment.setTitleColor(#colorLiteral(red: 0.6901960784, green: 0.6901960784, blue: 0.6901960784, alpha: 1), for: .normal)
        }
        if let url = URL(string: dataSource?.profilePic ?? "") {
            ivUserProfile.af_setImage(withURL: url)
            ivUserProfile.contentMode = .scaleAspectFill
        } else {
            ivUserProfile.image = #imageLiteral(resourceName: "feeds_user_placeholder")
            ivUserProfile.contentMode = .scaleAspectFit
        }
        if let url = URL(string: dataSource?.image ?? "") {
            iVFeed.af_setImage(withURL: url)
            heightConstraint.constant = 160
        } else {
            iVFeed.image = UIImage()
            heightConstraint.constant = 0
        }
        if (dataSource?.comments.count ?? 0) > 0 {
            self.emptyView.isHidden = true
            self.tableView.isHidden = false
        } else {
            self.tableView.isHidden = true
            self.emptyView.isHidden = false
        }
        self.tableView.reloadData()
    }
}

//MARK:- Table View Cell Class
class CommentTableCellText: UITableViewCell {
    @IBOutlet weak var lblNameUserComment: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblCommentTime: UILabel!
    @IBOutlet weak var ivUserComment: UIImageView!
    @IBOutlet weak var ivBlue: UIImageView!
    @IBOutlet weak var widthBlue: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var profileView: UIControl!
    
}
//MARK: Table View Cell Class
class CommentTableCellImage: UITableViewCell {
    @IBOutlet weak var ivComment: UIImageView!
    @IBOutlet weak var lblNameUserComment: UILabel!
    @IBOutlet weak var lblCommentTime: UILabel!
    @IBOutlet weak var ivUserComment: UIImageView!
    @IBOutlet weak var profileView: UIControl!
    @IBOutlet weak var azoomImgView: UIControl!
    @IBOutlet weak var ivBlue: UIImageView!
    @IBOutlet weak var widthBlue: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
}
