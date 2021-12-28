//
//  WodsVC.swift
//  VIKFIT
//

import UIKit
import SPStorkController

class WodsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    var dataSource = [WODModal]()
    let defaults = UserDefaults.standard
    var isWillApper = false
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addPullToRefresh()
        if UserDefaults.standard.bool(forKey: "isPurchased") {
            getReciept(false)
        } else {
            apiWorkOfDayData(false)
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
    override func viewDidAppear(_ animated: Bool) {
        Global.dismissLoadingSpinner()
    }
    override func viewWillDisappear(_ animated: Bool) {
        Global.dismissLoadingSpinner()
    }
}

//MARK:- Button Actions
extension WodsVC {
    //Mark: Action To see All Videos
    @IBAction func actionSeeAllVideos(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.dismissTooltips()
        if UserModel.getUserModel() == nil {
            let loginVC = StoryBoard.Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let transitionDelegate = SPStorkTransitioningDelegate()
            loginVC.transitioningDelegate = transitionDelegate
            loginVC.modalPresentationStyle = .custom
            loginVC.modalPresentationCapturesStatusBarAppearance = true
            transitionDelegate.showIndicator = false
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            getNav.present(loginVC, animated: true, completion: nil)
        } else {
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "VideosVC") as! VideosVC
            aboutVC.type = dataSource[sender.tag].type
            aboutVC.strTittle = dataSource[sender.tag].title
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
        }
    }
    
    //Mark: Action To See All News
    @IBAction func actionSeeAllNews(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.dismissTooltips()
        if UserModel.getUserModel() == nil {
            let loginVC = StoryBoard.Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let transitionDelegate = SPStorkTransitioningDelegate()
            loginVC.transitioningDelegate = transitionDelegate
            loginVC.modalPresentationStyle = .custom
            loginVC.modalPresentationCapturesStatusBarAppearance = true
            transitionDelegate.showIndicator = false
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            getNav.present(loginVC, animated: true, completion: nil)
        } else  {
            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
            aboutVC.type = dataSource[sender.tag].type
            aboutVC.strTittle = dataSource[sender.tag].title
            aboutVC.isNutrition = dataSource[sender.tag].isNutrition ?? false
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            getNav.present( rootNavView, animated: true, completion: nil)
        }
    }
}

//MARK:- Table View DataSource Methods
extension WodsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WodsTableTopCell", for: indexPath) as! WodsTableTopCell
            if dataSource[indexPath.row].data.count <= 1 {
                cell.btnNext.setImage(#imageLiteral(resourceName: "privious_disable"), for: .normal)
                cell.btnNext.isUserInteractionEnabled = false
                cell.btnPrevious.setImage(#imageLiteral(resourceName: "next_disable"), for: .normal)
                cell.btnPrevious.isUserInteractionEnabled = false
            } else {
                cell.btnNext.isUserInteractionEnabled = true
                cell.btnPrevious.isUserInteractionEnabled = true
            }
            cell.wodsVC = self
            cell.dataSource = dataSource[indexPath.row].data
            for (index, data) in dataSource[indexPath.row].data.enumerated() {
                if data.isFirst ?? false {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(item: index, section: 0)
                        cell.collectionView?.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                    }
                }
            }
            cell.collectionView.reloadData()
            return cell
        } else {
            if dataSource[indexPath.row].isVideo {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableCell", for: indexPath) as! VideoTableCell
                cell.btnAllExercise.tag = indexPath.row
                cell.wodsVC = self
                cell.lblHeading.text = dataSource[indexPath.row].title
                cell.dataSource = dataSource[indexPath.row].data
                cell.collectionView.reloadData()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableCell", for: indexPath) as! ActivityTableCell
                cell.btnBlog.tag = indexPath.row
                cell.wodsVC = self
                cell.isNutrition = dataSource[indexPath.row].isNutrition
                cell.lblHeading.text = dataSource[indexPath.row].title
                cell.dataSource = dataSource[indexPath.row].data
                cell.collectionView.reloadData()
                return cell
            }
        }
    }
    //MARK: Tool Tip Dismiss On Scroll
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissTooltips()
    }
    //MARK: Tool Tip Dismissal Function
    func dismissTooltips() {
        UserDefaults.standard.set(true, forKey: "isToolTipHide")
        guard let cell = tableView.visibleCells[0] as? WodsTableTopCell else {
            return
        }
        guard let cell1 = cell.collectionView.visibleCells[0] as? WodsCollectionFirst else {
            return
        }
        cell.tipView?.dismiss()
        cell1.tipView1?.dismiss()
        if let tbc = tabBarController as? TabBarController {
            tbc.tipView?.dismiss()
        }
    }
}

//MARK:- Pull to refresh
extension WodsVC {
    
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        apiWorkOfDayData(true)
    }
}

//MARK: Table View Delegates Methods
extension WodsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: API Call
extension WodsVC {
    func getReciept(_ isRefresh: Bool) {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            //            #if DEBUG
            //            let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
            //            #else
            let urlString = "https://buy.itunes.apple.com/verifyReceipt"
            //            #endif
            guard let receiptURL = Bundle.main.appStoreReceiptURL, let receiptString = try? Data(contentsOf: receiptURL).base64EncodedString(), let url = URL(string: urlString) else {
                self.apiWorkOfDayData(false)
                return
            }
            if !isRefresh {
                DispatchQueue.main.async {
                    Global.showLoadingSpinner()
                }
            }
            let requestData : [String : Any] = ["receipt-data" : receiptString,
                                                "password" : Constants.kAppDelegate.appSharedSecrateKey,
                                                "exclude-old-transactions" : true]
            let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
            URLSession.shared.dataTask(with: request)  { (data, response, error) in
                DispatchQueue.main.async {
                    if !isRefresh {
                        DispatchQueue.main.async {
                            Global.dismissLoadingSpinner()
                        }
                    }
                    if let data = data, let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                            let decoder = JSONDecoder()
                            let dataSource = try decoder.decode(ReciptModel.self, from: jsonData)
                            for reciept in dataSource.latestReceiptInfo {
                                let defaults = UserDefaults.standard
                                let dict = ["transaction_id": reciept.transactionID ?? "", "type": "premium", "productID": reciept.productID ?? ""] as [String : Any]
                                defaults.set(dict, forKey: "ReceiptInfo")
                                defaults.synchronize()
                                self.apiWorkOfDayData(false)
                            }
                        } catch let err {
                            self.apiWorkOfDayData(isRefresh)
                            print("Err", err)
                        }
                    }
                }
            }.resume()
        } else {
            self.apiWorkOfDayData(isRefresh)
        }
    }
    
    func apiWorkOfDayData(_ isRefresh: Bool) {
        let userId = UserModel.getUserModel()?.id ?? ""
        var param = ["user_id": userId, "transaction_id": "", "type": "free"]
        if let receiptInfo = defaults.object(forKey: "ReceiptInfo") as? [String: Any] {
            param = ["user_id": userId, "transaction_id": receiptInfo["transaction_id"] as! String, "type": receiptInfo["type"] as! String]
        }
        if let getRequest = API.DASHBOARD.request(method: .post, with: param, forJsonEncoding: true) {
            if !isRefresh {
                DispatchQueue.main.async {
                    Global.showLoadingSpinner()
                }
            }
            getRequest.responseJSON { (response) in
                if !isRefresh {
                    DispatchQueue.main.async {
                        Global.dismissLoadingSpinner()
                    }
                }
                API.DASHBOARD.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [[String: Any]] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.dataSource = try decoder.decode([WODModal].self, from: jsonData)
                        
                        if let badgeCount = jsonObject?["badge"] as? Int, badgeCount > 0 {
                            self.tabBarController?.viewControllers?[4].tabBarItem.badgeColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
                            self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = "\(badgeCount)"
                        } else {
                            self.tabBarController?.viewControllers?[4].tabBarItem.badgeColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 0)
                            self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = ""
                        }
                        
                        if isRefresh {
                            self.refreshControl.endRefreshing()
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
