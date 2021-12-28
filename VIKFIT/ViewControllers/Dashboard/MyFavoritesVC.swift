//
//  MyFavoritesVC.swift
//  VIKFIT
//


import UIKit
import AlamofireImage

class MyFavoritesVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK:- Properties
    var dataSource = [MyFavoriteListModel]()
    private let refreshControl = UIRefreshControl()
    var pageNo = 1
    var isLoading = true
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isHidden = false
        emptyView.isHidden = false
        DispatchQueue.main.async {
            Global.dismissLoadingSpinner()
            self.apiMyFavoritesList(false, pageNo: self.pageNo)
        }
        addPullToRefresh()
    }
    override func viewDidAppear(_ animated: Bool) {
        Global.dismissLoadingSpinner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Global.dismissLoadingSpinner()
    }
}
//MARK:- Buttons Action
extension MyFavoritesVC {
    
    //Mark:Function For Removing Empty View
    @IBAction func showTable(_ sender: UIView) {
        //        tableView.isHidden = false
        //        emptyView.isHidden = true
    }
    
    //Mark: Action For Fav Button
    @IBAction func aactionTapFev(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        apiFavorite(id: dataSource[sender.tag].id, index: sender.tag)
    }
}

//MARK:- Pull to refresh
extension MyFavoritesVC {
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    @objc private func refreshWeatherData(_ sender: Any) {
        isLoading = true
        pageNo = 1
        apiMyFavoritesList(true, pageNo: 1)
    }
}
//MARK:-TableView DataSource Methods
extension MyFavoritesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FevTableCell", for: indexPath) as! FevTableCell
        cell.btnFev.tag = indexPath.row
        cell.btnFev.setImage(#imageLiteral(resourceName: "fev_selected"), for: .normal)
        cell.lblName.text = dataSource[indexPath.row].title
        cell.lblType.text = dataSource[indexPath.row].exercise
        
        if let url = URL(string: dataSource[indexPath.row].thumbURL) {
            cell.videoImg.af_setImage(withURL: url)
        }
        if indexPath.row == dataSource.count {
            cell.lblSaprator.isHidden = true
        } else {
            cell.lblSaprator.isHidden = false
        }
        if isLoading {
            if indexPath.row == dataSource.count - 1 {
                apiMyFavoritesList(true, pageNo: pageNo)
            }
        }
        return cell
    }
}
//MARK:-TableView Delegates Methods
extension MyFavoritesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "ExerciseVC") as! ExerciseVC
        aboutVC.exerciseID = dataSource[indexPath.row].id
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        rootNavView.modalPresentationStyle = .fullScreen
        getNav.present( rootNavView, animated: true, completion: nil)
    }
}

//MARK: API Call
extension MyFavoritesVC {
    func apiMyFavoritesList(_ isRefresh: Bool, pageNo: Int) {
        
        guard let userId = UserModel.getUserModel()?.id else {
            if isRefresh {
                self.refreshControl.endRefreshing()
            }
            return
        }
        
        let param:[String: Any] = ["user_id": userId, "page": pageNo]
        if let getRequest = API.FAVORITELIST.request(method: .post, with: param, forJsonEncoding: true) {
            if !isRefresh {
                Global.showLoadingSpinner()
            }
            getRequest.responseJSON { (response) in
                if !isRefresh {
                    Global.dismissLoadingSpinner()
                }
                API.FAVORITELIST.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [[String: Any]] else {
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
                        let data = try decoder.decode([MyFavoriteListModel].self, from: jsonData)
                        self.dataSource.append(contentsOf: data)
                        if self.dataSource.count != 0 {
                            self.tableView.isHidden = false
                            self.emptyView.isHidden = true
                        } else {
                            self.emptyView.isHidden = false
                        }
                        
                        if isRefresh {
                            self.refreshControl.endRefreshing()
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
    
    //MARK:-  Api Favorite
    func apiFavorite(id: String, index: Int) {
        
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "exercise_id": id]
        print(param)
        
        if let getRequest = API.FAVORITE.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.FAVORITE.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.dataSource.remove(at: index)
                    self.tableView.reloadData()
                })
            }
        }
    }
}

//MARK:-TableView Cell Class
class FevTableCell: UITableViewCell {
    @IBOutlet weak var lblSaprator: UILabel!
    @IBOutlet weak var btnFev: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var videoImg: UIImageView!
    @IBOutlet weak var playBurronImg: UIImageView!
}
