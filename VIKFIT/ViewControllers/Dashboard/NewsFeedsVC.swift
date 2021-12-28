//
//  NewsFeedsVC.swift
//  VIKFIT
//

import UIKit
import MBProgressHUD

class NewsFeedsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var lblFilter: UILabel!
    
    private let refreshControl = UIRefreshControl()
    var type = "all"
    var pageNo = 1
    var isLoading = true
    var dataSource = [FeedsModal]()
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addPullToRefresh()
    }
    override func viewWillAppear(_ animated: Bool) {
        apiGetFeeds(false, pageNo: pageNo)
    }
    override func viewWillDisappear(_ animated: Bool) {
        dismissLoadingSpinner()
    }
}

//MARK:- Buttons Action
extension NewsFeedsVC {
    //Mark: Action for Image picker
    @IBAction func actionOpenPhoto(_ sender: UIButton) {
        showImagePickerView()
    }
    //Mark: Action For profile Tap
    @IBAction func actionTapProfile(_ sender: UIControl) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let userId = UserModel.getUserModel()?.id, userId != "\(dataSource[sender.tag].userID)" else {
            return
        }
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
        aboutVC.otherUserId = "\(dataSource[sender.tag].userID)"
        aboutVC.previousController = self
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    //Mark: Action for New Messages
    @IBAction func actionNewMessages(_ sender: UIView) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "NewMessageVC") as! NewMessageVC
        aboutVC.newsFeedsVC = self
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    //Mark:Button More Action
    @IBAction func actionBtnMore(_ sender: UIButton) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        if String(userId) == dataSource[sender.tag].userID {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let edit = UIAlertAction(title: "Edit".localized, style: .default){ _ in
                let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "NewMessageVC") as! NewMessageVC
                aboutVC.newsFeedsVC = self
                aboutVC.perivousText = self.dataSource[sender.tag].feedMessage
                aboutVC.editPost = true
                aboutVC.postID = self.dataSource[sender.tag].id
                aboutVC.images = self.dataSource[sender.tag].image
                aboutVC.previousIndex = sender.tag
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
            }
            let delete = UIAlertAction(title: Messages.txtDeleteTitleNewsFeed, style: .destructive){ _ in
                let alert  = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.txtDeletePost, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Messages.txtDeleteConfirm, style: .destructive, handler: { _ in
                    self.apiDeletePost(sender.tag)
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
            let optionMenu = UIAlertController(title: Messages.txtReportPubTitleNewsFeed, message: Messages.txtAlertMesNewsFeed, preferredStyle: .actionSheet)
            let allUsers = UIAlertAction(title: Messages.txtReportPubTitleNewsFeed, style: .destructive){ _ in
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: Messages.txtReportThePubTitleNewsFeed, message: Messages.txtIndicateMesNewsFeed, preferredStyle: .alert)
                    
                    let saveAction = UIAlertAction(title: Messages.txtSettingSend, style: .destructive, handler: { alert -> Void in
                        let firstTextField = alertController.textFields![0] as UITextField
                        if firstTextField.text?.trim().count == 0 {
                            Common.showAlertMessage(message: Messages.txtreportDetailMesNewsFeed, alertType: .error)
                            return
                        }
                        self.apiReportOnPost(sender.tag, reason: firstTextField.text!)
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
    //Mark:Report comment Button Action
    @IBAction func actionLikeFeed(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        apiLikeUnlike(sender.tag)
        
    }
    //Mark:Filter Button Action
    @IBAction func actionFilter(_ sender: UIView) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let allUsers = UIAlertAction(title: Messages.txtAllUserNewsFeed, style: .default){ _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if self.type != "all" {
                self.type = "all"
                self.isLoading = true
                self.pageNo = 1
                self.apiGetFeeds(false, pageNo: self.pageNo)
            }
            self.lblFilter.text = Messages.txtAllUserNewsFeed
        }
        let mySubs = UIAlertAction(title: Messages.txtMySubNewsFeed, style: .default){ _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.lblFilter.text = Messages.txtMySubNewsFeed
            if self.type != "user" {
                self.type = "user"
                self.isLoading = true
                self.pageNo = 1
                self.apiGetFeeds(false, pageNo: self.pageNo)
            }
        }
        let teamCross = UIAlertAction(title: Messages.txtTeamCrossfitNewsFeed, style: .default){ _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.lblFilter.text = Messages.txtTeamCrossfitNewsFeed
            if self.type != "team" {
                self.type = "team"
                self.isLoading = true
                self.pageNo = 1
                self.apiGetFeeds(false, pageNo: self.pageNo)
            }
        }
        
        let cancelAction = UIAlertAction(title: Messages.txtDeleteCancel, style: .cancel)
        optionMenu.addAction(allUsers)
        optionMenu.addAction(mySubs)
        optionMenu.addAction(teamCross)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    //Mark:Function For Removing Empty View
    @IBAction func showTable(_ sender: UIView) {
    }
    //Mark:Button Comment Action
    @IBAction func actionBtnComment(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        aboutVC.postId = dataSource[sender.tag].id
        aboutVC.images = dataSource[sender.tag].image
        aboutVC.newsFeedVC = self
        aboutVC.previousIndex = sender.tag
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
}
//MARK:- Pull to refresh
extension NewsFeedsVC {
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        isLoading = true
        pageNo = 1
        apiGetFeeds(true, pageNo: pageNo)
    }
}
//MARK:-TableView DataSource Methods
extension NewsFeedsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedsTableCell", for: indexPath) as! NewsFeedsTableCell
        cell.btnSupport.tag = indexPath.row
        cell.btnMore.tag = indexPath.row
        cell.btnComment.tag = indexPath.row
        cell.feedUserProfileView.tag = indexPath.row
        cell.lblMessage.text = dataSource[indexPath.row].feedMessage
        cell.lblUserName.text = dataSource[indexPath.row].firstName
        cell.ivVerified.isHidden = !dataSource[indexPath.row].verified
        cell.lblPostTime.text = dataSource[indexPath.row].createdAt
        if dataSource[indexPath.row].likes > 1 {
            cell.btnSupport.setTitle("\(Messages.txtSupports) (\(dataSource[indexPath.row].likes))", for: .normal)
        } else {
            cell.btnSupport.setTitle("\(Messages.txtSupport) (\(dataSource[indexPath.row].likes))", for: .normal)
        }
        if dataSource[indexPath.row].comments > 1 {
            cell.btnComment.setTitle("\(Messages.txtComments) (\(dataSource[indexPath.row].comments))", for: .normal)
        } else {
            cell.btnComment.setTitle("\(Messages.txtComment) (\(dataSource[indexPath.row].comments))", for: .normal)
        }
        
        cell.imageArr = dataSource[indexPath.row].image
        cell.collectionView.reloadData()
        if let userimgUrl = URL(string: dataSource[indexPath.row].profilePic) {
            cell.ivUser.af_setImage(withURL: userimgUrl)
            cell.ivUser.contentMode = .scaleAspectFill
        } else {
            cell.ivUser.image = #imageLiteral(resourceName: "feeds_user_placeholder")
            cell.ivUser.contentMode = .scaleAspectFit
        }
        
        if dataSource[indexPath.row].image.count > 0 {
            cell.imageHight.constant = 240
        } else {
            cell.imageHight.constant = 0
        }
        
        if dataSource[indexPath.row].userLike {
            cell.btnSupport.setImage(#imageLiteral(resourceName: "clapping copy"), for: .normal)
            cell.btnSupport.setTitleColor(#colorLiteral(red: 0, green: 1, blue: 0.7764705882, alpha: 1), for: .normal)
            
        } else {
            cell.btnSupport.setImage(#imageLiteral(resourceName: "feed_support"), for: .normal)
            cell.btnSupport.setTitleColor(#colorLiteral(red: 0.6901960784, green: 0.6901960784, blue: 0.6901960784, alpha: 1), for: .normal)
        }
        if dataSource[indexPath.row].userComment {
            cell.btnComment.setImage(#imageLiteral(resourceName: "feed_comment"), for: .normal)
            cell.btnComment.imageView?.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.5019607843, alpha: 1)
            cell.btnComment.setTitleColor(#colorLiteral(red: 1, green: 0, blue: 0.5019607843, alpha: 1), for: .normal)
            
        } else {
            cell.btnComment.setImage(#imageLiteral(resourceName: "feed_comment"), for: .normal)
            cell.btnComment.imageView?.tintColor = #colorLiteral(red: 0.6901960784, green: 0.6901960784, blue: 0.6901960784, alpha: 1)
            cell.btnComment.setTitleColor(#colorLiteral(red: 0.6901960784, green: 0.6901960784, blue: 0.6901960784, alpha: 1), for: .normal)
        }
        if isLoading {
            if indexPath.row == dataSource.count - 1 {
                apiGetFeeds(true, pageNo: pageNo)
            }
        }
        return cell
    }
}
//MARK:-TableView Delegate Methods
extension NewsFeedsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
//MARK: UIImagePickerController Config
extension NewsFeedsVC {
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
extension NewsFeedsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.editedImage] as? UIImage else {
            return
            //apiAddFeed(image: pickedImage)
        }
        picker.dismiss(animated: true) {
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "NewMessageVC") as! NewMessageVC
            aboutVC.newsFeedsVC = self
            aboutVC.arrImages[0] = pickedImage
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
        }
    }
}

//MARK: API Call Blog
extension NewsFeedsVC {
    func apiGetFeeds(_ isRefresh: Bool, pageNo: Int) {
        guard let userId = UserModel.getUserModel()?.id else {
            if isRefresh {
                self.refreshControl.endRefreshing()
            }
            return
        }
        let param:[String: Any] = ["user_id": userId, "type": type, "page": pageNo]
        
        if let getRequest = API.GETFEEDS.request(method: .post, with: param, forJsonEncoding: true) {
            if !isRefresh {
                showLoadingSpinner()
            }
            getRequest.responseJSON { (response) in
                if !isRefresh {
                    self.dismissLoadingSpinner()
                }
                API.GETFEEDS.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [[String: Any]] else {
                        self.dataSource.removeAll()
                        self.emptyView.isHidden = false
                        self.tableView.reloadData()
                        return
                    }
                    if getData.count == 0 {
                        self.isLoading = false
                        return
                    }
                    if pageNo == 1 {
                        self.dataSource.removeAll()
                    }
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        let data = try decoder.decode([FeedsModal].self, from: jsonData)
                        self.dataSource.append(contentsOf: data)
                        if isRefresh {
                            self.refreshControl.endRefreshing()
                        }
                        if self.dataSource.count > 0 {
                            self.emptyView.isHidden = true
                        } else {
                            self.emptyView.isHidden = false
                        }
                        self.pageNo = self.pageNo + 1
                        self.tableView.reloadData()
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
    
    func apiLikeUnlike(_ index: Int) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "post_id": dataSource[index].id]
        
        if let getRequest = API.LIKEPOST.request(method: .post, with: param, forJsonEncoding: true) {
            showLoadingSpinner()
            getRequest.responseJSON { (response) in
                self.dismissLoadingSpinner()
                API.LIKEPOST.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.dataSource[index].userLike = !self.dataSource[index].userLike
                    if self.dataSource[index].userLike {
                        self.dataSource[index].likes = (self.dataSource[index].likes) + 1
                    } else {
                        self.dataSource[index].likes = (self.dataSource[index].likes) - 1
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func apiReportOnPost(_ index: Int, reason: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "post_id": dataSource[index].id, "reason": reason]
        
        if let getRequest = API.REPORTONFEED.request(method: .post, with: param, forJsonEncoding: true) {
            showLoadingSpinner()
            getRequest.responseJSON { (response) in
                self.dismissLoadingSpinner()
                API.REPORTONFEED.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: Messages.txtReportOnPostMes, alertType: .success)
                    self.tableView.reloadData()
                    
                })
            }
        }
    }
    
    func apiDeletePost(_ index: Int) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "post_id": dataSource[index].id]
        
        if let getRequest = API.DELETEPOST.request(method: .post, with: param, forJsonEncoding: true) {
            showLoadingSpinner()
            getRequest.responseJSON { (response) in
                self.dismissLoadingSpinner()
                API.DELETEPOST.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                    self.dataSource.remove(at: index)
                    self.tableView.reloadData()
                    
                })
            }
        }
    }
    
    //    func apiAddFeed(image: UIImage) {
    //        guard let userId = UserModel.getUserModel()?.id else {
    //            return
    //        }
    //        let param:[String: Any] = ["user_id": userId, "description": ""]
    //        showLoadingSpinner()
    //        API.ADDFEED.requestUpload(with: param, files: ["uploadFile[0]": image]) { (response, error) in
    //            self.dismissLoadingSpinner()
    //            guard error == nil else {
    //                return
    //            }
    //            self.apiGetFeeds(false)
    //        }
    //    }
    
    
    func showLoadingSpinner() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.tintColor = .black
        hud.show(animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func dismissLoadingSpinner() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        MBProgressHUD.hide(for:self.view, animated: true)
    }
}

//MARK:-TableView Cell Class
class NewsFeedsTableCell: UITableViewCell {
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lblPostTime: UILabel!
    @IBOutlet weak var ivVerified: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var btnSupport: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imageHight: NSLayoutConstraint!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var feedUserProfileView: UIControl!
    @IBOutlet weak var collectionView: UICollectionView!
    var imageArr = [String]()
    override func awakeFromNib() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension NewsFeedsTableCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "GalleryImageVC") as! GalleryImageVC
        aboutVC.imgStr  = imageArr[indexPath.row]
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
    
}
extension NewsFeedsTableCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionImageCell", for: indexPath) as! FeedCollectionImageCell
        
        if let imgUrl = URL(string: imageArr[indexPath.row]) {
            cell.ivPost.af_setImage(withURL: imgUrl)
        }
        return cell
    }
}
extension NewsFeedsTableCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 1.2, height: collectionView.frame.height)
    }
}

class FeedCollectionImageCell: UICollectionViewCell {
    @IBOutlet weak var ivPost: UIImageView!
    
}
