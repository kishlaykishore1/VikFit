//
//  NewsVC.swift
//  VIKFIT
//

import UIKit

class NewsVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var type: String?
    var dataSource = [BlogModel]()
    var BlogSearchArry = [BlogModel]()
    var strTittle = ""
    var isNutrition = false
    var pageNo = 1
    var isLoading = true
    var searchString = ""
    private let refreshControl = UIRefreshControl()
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        apiListAllBlog(false, pageNo: pageNo)
        addPullToRefresh()
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
        self.title = strTittle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 17)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)]
    }
    override func backBtnTapAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:-Table View DataSource Methods
extension NewsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BlogSearchArry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "NewsTableCell", for: indexPath) as! NewsTableCell
        cell.lblTitle.text = BlogSearchArry[indexPath.row].title
        cell.lblDate.text = BlogSearchArry[indexPath.row].datePublication
        cell.ivLock.isHidden = true
//        if isNutrition {
//            cell.ivLock.isHidden = false
//            if let receiptInfo = UserDefaults.standard.object(forKey: "ReceiptInfo") as? [String: Any] {
//                if receiptInfo["type"] as! String == "premium" {
//                    cell.ivLock.isHidden = true
//                }
//            }
//        }
        if isLoading {
            if indexPath.row == dataSource.count - 1 {
                apiListAllBlog(true, pageNo: pageNo)
            }
        }
        return cell
    }
}

//MARK:-Table View Delegates Methods
extension NewsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isNutrition {
//            guard let receiptInfo = UserDefaults.standard.object(forKey: "ReceiptInfo") as? [String: Any] else {
//                Common.showAlertMessage(message: Messages.mustSubscribe, alertType: .warning)
//                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
//                aboutVC.isFromHome = true
//                guard let getNav = UIApplication.topViewController()?.navigationController else {
//                    return
//                }
//                let rootNavView = UINavigationController(rootViewController: aboutVC)
//                rootNavView.modalPresentationStyle = .fullScreen
//                if #available(iOS 13.0, *) {
//                    getNav.isModalInPresentation = true
//                }
//                getNav.present( rootNavView, animated: true, completion: nil)
//                return
//            }
//            if receiptInfo["type"] as! String == "premium" {
                let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "BlogArticalsVC") as! BlogArticalsVC
                aboutVC.blogId = dataSource[indexPath.row].id
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
//            } else {
//                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
//                aboutVC.isFromHome = true
//                guard let getNav = UIApplication.topViewController()?.navigationController else {
//                    return
//                }
//                let rootNavView = UINavigationController(rootViewController: aboutVC)
//                rootNavView.modalPresentationStyle = .fullScreen
//                if #available(iOS 13.0, *) {
//                    getNav.isModalInPresentation = true
//                }
//                getNav.present( rootNavView, animated: true, completion: nil)
//            }
        } else {
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "BlogArticalsVC") as! BlogArticalsVC
            aboutVC.blogId = dataSource[indexPath.row].id
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
        }
    }
}

//MARK:-Search Bar Delegates Methods
extension NewsVC: UISearchBarDelegate {
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
        searchString = ""
        pageNo = 1
        isLoading = true
        apiListAllBlog(true, pageNo: 1)
        //        BlogSearchArry = dataSource
        //        if BlogSearchArry.count == 0 {
        //            tableView.isHidden = true
        //        } else {
        //            tableView.isHidden = false
        //        }
        //        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        pageNo = 1
        isLoading = true
        apiListAllBlog(true, pageNo: 1)
        //        guard !searchText.isEmpty else {
        //            BlogSearchArry = dataSource
        //            if BlogSearchArry.count == 0 {
        //                tableView.isHidden = true
        //            } else {
        //                tableView.isHidden = false
        //            }
        //            tableView.reloadData()
        //            return
        //        }
        //        BlogSearchArry = dataSource.filter({ (data) -> Bool in
        //            data.title.lowercased().contains(searchText.lowercased())
        //        })
        //        if BlogSearchArry.count == 0 {
        //            tableView.isHidden = true
        //        } else {
        //            tableView.isHidden = false
        //        }
        //        tableView.reloadData()
    }
}


//MARK:- Pull to refresh
extension NewsVC {
    
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        isLoading = true
        pageNo = 1
        apiListAllBlog(true, pageNo: 1)
    }
}

//MARK: API Call Blog
extension NewsVC {
    func apiListAllBlog(_ isRefresh: Bool, pageNo: Int) {
        guard let userId = UserModel.getUserModel()?.id else {
            if isRefresh {
                self.refreshControl.endRefreshing()
            }
            return
        }
        
        let param:[String: Any] = ["user_id": userId, "type": type ?? "", "page": pageNo, "search": searchString]
        if let getRequest = API.LISTALL.request(method: .post, with: param, forJsonEncoding: true) {
            if !isRefresh {
                Global.showLoadingSpinner()
            }
            getRequest.responseJSON { (response) in
                if !isRefresh {
                    Global.dismissLoadingSpinner()
                }
                API.LISTALL.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [[String: Any]] else {
                        return
                    }
                    if getData.count == 0 {
                        self.isLoading = false
//                        return
                    }
                    if pageNo == 1 {
                        self.dataSource.removeAll()
                        self.BlogSearchArry.removeAll()
                        self.tableView.reloadData()
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        let data = try decoder.decode([BlogModel].self, from: jsonData)
                        self.dataSource.append(contentsOf: data)
                        self.BlogSearchArry = self.dataSource
                        if isRefresh {
                            self.refreshControl.endRefreshing()
                        }
                        if self.BlogSearchArry.count == 0 {
                            self.tableView.isHidden = true
                        } else {
                            self.tableView.isHidden = false
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
}

//MARK:-TableView cell Class
class NewsTableCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivLock: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    
}
