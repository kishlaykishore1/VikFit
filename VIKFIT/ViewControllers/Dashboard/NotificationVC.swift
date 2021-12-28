//
//  NotificationVC.swift
//  VIKFIT
//

import UIKit

class NotificationVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var lblBedgeCount: UILabel!
    @IBOutlet weak var bedgeCountView: DesignableButton!
    
    //MARK:- Properties
    private let refreshControl = UIRefreshControl()
    var dataSource = [NotificationListModel]()
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        bedgeCountView.isHidden = true
        emptyView.isHidden = false
        UIApplication.shared.applicationIconBadgeNumber = 0
        DispatchQueue.main.async {
            Global.dismissLoadingSpinner()
            self.apiNotificationList(false)
            
        }
        addPullToRefresh()
    }
    override func viewWillDisappear(_ animated: Bool) {
        Global.dismissLoadingSpinner()
    }
}
//MARK:- Pull to refresh
extension NotificationVC {
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    @objc private func refreshWeatherData(_ sender: Any) {
        apiNotificationList(true)
    }
}
//MARK:-TableView DataSource Methods
extension NotificationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableCell", for: indexPath) as! NotificationTableCell
        cell.lblTitle.text = dataSource[indexPath.row].title
        cell.lblSubTitle.text = "\(dataSource[indexPath.row].message) \(dataSource[indexPath.row].createdAt)"
        if dataSource[indexPath.row].seen == true {
            cell.backgroundColor = .clear
            cell.newNotiView.isHidden = true
            cell.lblTitle.font = UIFont(name: "Poppins-Regular", size: 12)
        } else {
            cell.backgroundColor = .white
            cell.newNotiView.isHidden = false
            cell.lblTitle.font =  UIFont(name: "Poppins-SemiBold", size: 12)
        }
        
        if dataSource[indexPath.row].imageLink.isEmpty {
            cell.ivHeight.constant = 0
            cell.ivPicture.isHidden = true
        } else {
            
            if let url = URL(string: dataSource[indexPath.row].imageLink) {
                cell.ivPicture.af_setImage(withURL: url)
                cell.ivHeight.constant = 32
                cell.ivPicture.isHidden = false
            } else {
                cell.ivHeight.constant = 0
                cell.ivPicture.isHidden = true
            }
            
        }
        return cell
    }
}
//MARK:-TableView Delegate Methods
extension NotificationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        //        let id = dataSource[indexPath.row].id
        //apiNotificationSeen(NotificationId: id)
        self.apiNotificationList(true)
        switch dataSource[indexPath.row].type {
        case "profile":
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
            aboutVC.otherUserId = "\(dataSource[indexPath.row].userID)"
            aboutVC.previousController = self
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        case "post_view":
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            aboutVC.postId = dataSource[indexPath.row].postID
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        case "home":
            self.tabBarController?.selectedIndex = 0
            break
        case "payment":
            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
            aboutVC.isFromHome = true
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            rootNavView.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                getNav.isModalInPresentation = true
            }
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        case "url":
            if let url = URL(string: dataSource[indexPath.row].link) {
                UIApplication.shared.open(url)
            }
            break
        case "article":
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "BlogArticalsVC") as! BlogArticalsVC
            aboutVC.blogId = dataSource[indexPath.row].postID
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        case "exercise":
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "ExerciseVC") as! ExerciseVC
            aboutVC.exerciseID = dataSource[indexPath.row].postID
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            rootNavView.modalPresentationStyle = .fullScreen
            getNav.present( rootNavView, animated: true, completion: nil)
            break
        default:
            self.tabBarController?.selectedIndex = 4
            break
        }
    }
}

//MARK: API Call Blog
extension NotificationVC {
    func apiNotificationList(_ isRefresh: Bool) {
        guard let userId = UserModel.getUserModel()?.id else {
            if isRefresh {
                self.refreshControl.endRefreshing()
            }
            return
        }
        let param:[String: Any] = ["user_id": userId]
        if let getRequest = API.NOTIFICATIONLIST.request(method: .post, with: param, forJsonEncoding: true) {
            if !isRefresh {
                Global.showLoadingSpinner()
            }
            getRequest.responseJSON { (response) in
                if !isRefresh {
                    Global.dismissLoadingSpinner()
                } else {
                    self.refreshControl.endRefreshing()
                }
                
                API.NOTIFICATIONLIST.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    
                    guard let count = jsonObject?["un_seen_count"] as? Int else {
                        return
                    }
                    
                    guard error == nil, let getData = jsonObject?["data"] as? [[String: Any]] else {
                        return
                    }
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.dataSource = try decoder.decode([NotificationListModel].self, from: jsonData)
                        
                        if self.dataSource.count > 0 {
                            self.tableView.isHidden = false
                            self.emptyView.isHidden = true
                            self.lblBedgeCount.text = "\(count)"
                            self.bedgeCountView.isHidden = true
                            self.tabBarController?.viewControllers?[4].tabBarItem.badgeColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 0)
                            self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = ""
                            if count > 0 {
                                self.tabBarController?.viewControllers?[4].tabBarItem.badgeColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
                                self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = "\(count)"
                                self.bedgeCountView.isHidden = false
                            }
                        } else {
                            self.tableView.isHidden = true
                            self.bedgeCountView.isHidden = true
                            self.emptyView.isHidden = false
                        }
                        self.tableView.reloadData()
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
    
    //MARK:-  Api Notification Seen
    func apiNotificationSeen(NotificationId: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "notification_id": NotificationId]
        print(param)
        
        if let getRequest = API.NOTIFICATIONSEEN.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.NOTIFICATIONSEEN.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.apiNotificationList(true)
                })
            }
        }
    }
}

//MARK:- Table View Cell class
class NotificationTableCell: UITableViewCell {
    
    @IBOutlet weak var ivHeight: NSLayoutConstraint!
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var newNotiView: DesignableButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
}
