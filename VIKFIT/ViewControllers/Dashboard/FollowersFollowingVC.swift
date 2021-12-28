//
//  FollowersFollowingVC.swift
//  VIKFIT
//

import UIKit
import AlamofireImage

class FollowersFollowingVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var strTitle = ""
    var userId = ""
    private let refreshControl = UIRefreshControl()
    var dataSource = [FollowersModel]()
    var FollwerFollowingArray = [FollowersModel]() //Update Model searching
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addPullToRefresh()
        if strTitle == "Followers".localized || strTitle == "Follower".localized {
            apiFollowers(false)
        } else {
            apiFollowings(false)
        }
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = Messages.txtDeleteCancel
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.autocapitalizationType = .none
        } else {
            searchBar.autocapitalizationType = .none
        }
        self.navigationController?.isNavigationBarHidden = false
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        setBackButton(tintColor: #colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1), isImage: true)
        self.title = strTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 17)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)]
    }
}
//MARK:- Button Actions
extension FollowersFollowingVC {
    //Mark:Back Button Pressed
    override func backBtnTapAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK:-Table View DataSource Methods
extension FollowersFollowingVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FollwerFollowingArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersFollowingTableCell", for: indexPath) as! FollowersFollowingTableCell
        
        cell.lblName.text = "\(FollwerFollowingArray[indexPath.row].firstName)" + " \(FollwerFollowingArray[indexPath.row].lastName)"
        
        if let url = URL(string: FollwerFollowingArray[indexPath.row].profilePic) {
            cell.avtarImg.af_setImage(withURL: url)
            cell.avtarImg.contentMode = .scaleAspectFill
        } else {
            cell.avtarImg.image = #imageLiteral(resourceName: "avtar")
            cell.avtarImg.contentMode = .scaleAspectFit
        }
        
        if indexPath.row == FollwerFollowingArray.count {
            cell.lblSaprator.isHidden = true
        } else {
            cell.lblSaprator.isHidden = false
        }
        return cell
    }
}

//MARK:-Table View Delegates Methods
extension FollowersFollowingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        if userId != "\(dataSource[indexPath.row].id)" {
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            aboutVC.otherUserId = "\(FollwerFollowingArray[indexPath.row].id)"
            aboutVC.previousController = self
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
//MARK:-Search Bar Delegates Methods
extension FollowersFollowingVC: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        FollwerFollowingArray = dataSource
        if self.FollwerFollowingArray.count == 0 {
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            FollwerFollowingArray = dataSource
            if self.FollwerFollowingArray.count == 0 {
                self.tableView.isHidden = true
            } else {
                self.tableView.isHidden = false
            }
            tableView.reloadData()
            return
        }
        FollwerFollowingArray = dataSource.filter({ (data) -> Bool in
            
            let name = data.firstName + data.lastName
            return name.lowercased().contains(searchText.lowercased())
        })
        if self.FollwerFollowingArray.count == 0 {
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
        }
        tableView.reloadData()
    }
    
}

//MARK:- Pull to refresh
extension FollowersFollowingVC {
    
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        
        if strTitle == "Followers".localized {
            apiFollowers(true)
        } else {
            apiFollowings(true)
        }
    }
}

//MARK: API Call Followers
extension FollowersFollowingVC {
    func apiFollowers(_ isRefresh: Bool) {
        let param:[String: Any] = ["user_id": userId]
        if let getRequest = API.FOLLOWERS.request(method: .post, with: param, forJsonEncoding: true) {
            if !isRefresh {
                Global.showLoadingSpinner()
            }
            getRequest.responseJSON { (response) in
                if !isRefresh {
                    Global.dismissLoadingSpinner()
                }
                API.FOLLOWERS.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [[String: Any]] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.dataSource = try decoder.decode([FollowersModel].self, from: jsonData)
                        
                        self.FollwerFollowingArray = self.dataSource
                        
                        if isRefresh {
                            self.refreshControl.endRefreshing()
                        }
                        if self.FollwerFollowingArray.count == 0 {
                            self.tableView.isHidden = true
                        } else {
                            self.tableView.isHidden = false
                        }
                        self.tableView.reloadData()
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
    
    //MARK: API Call Following
    func apiFollowings(_ isRefresh: Bool) {
        let param:[String: Any] = ["user_id": userId]
        if let getRequest = API.FOLLOWINGS.request(method: .post, with: param, forJsonEncoding: true) {
            if !isRefresh {
                Global.showLoadingSpinner()
            }
            getRequest.responseJSON { (response) in
                if !isRefresh {
                    Global.dismissLoadingSpinner()
                }
                API.FOLLOWINGS.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [[String: Any]] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.dataSource = try decoder.decode([FollowersModel].self, from: jsonData)
                        
                        self.FollwerFollowingArray = self.dataSource
                        
                        if isRefresh {
                            self.refreshControl.endRefreshing()
                        }
                        if self.FollwerFollowingArray.count == 0 {
                            self.tableView.isHidden = true
                        } else {
                            self.tableView.isHidden = false
                        }
                        self.tableView.reloadData()
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
}

//MARK: Table View Cell Class
class FollowersFollowingTableCell: UITableViewCell {
    
    @IBOutlet weak var avtarImg: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSaprator: UILabel!
}
