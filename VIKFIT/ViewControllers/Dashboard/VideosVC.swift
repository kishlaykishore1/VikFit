//
//  VideosVC.swift
//  VIKFIT
//

import UIKit
import AlamofireImage

class VideosVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Propereties
    var type: String?
    var dataSource = [ExerciseModel]()
    var pageNo = 1
    var isLoading = true
    var ExerciseArray = [ExerciseModel]()
    var searchArray = [Any]()
    var strTittle = ""
    var searchString = ""
    private let refreshControl = UIRefreshControl()
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPullToRefresh()
        apiListAllExercise(false, pageNo: pageNo)
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
        self.title = "All standards".localized//strTittle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 17)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)]
    }
}
//MARK:- Button Action
extension VideosVC {
    //Mark: fav Button Tap Action
    @IBAction func aactionTapFev(_ sender: UIButton) {
        if sender.imageView?.image == #imageLiteral(resourceName: "fev_selected") {
            sender.setImage(#imageLiteral(resourceName: "fev"), for: .normal)
        } else {
            sender.setImage(#imageLiteral(resourceName: "fev_selected"), for: .normal)
        }
        apiFavorite(id: ExerciseArray[sender.tag].id, index: sender.tag)
    }
    //Mark:Back Button tap Action
    override func backBtnTapAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK:-Table View DataSource Methods
extension VideosVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExerciseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideosTableCell", for: indexPath) as! VideosTableCell
        cell.btnFev.tag = indexPath.row
        cell.lblName.text = ExerciseArray[indexPath.row].title
        cell.lblType.text = ExerciseArray[indexPath.row].exercise
        if let url = URL(string: ExerciseArray[indexPath.row].thumbURL) {
            cell.videoImg.af_setImage(withURL: url)
        }
        if indexPath.row == (ExerciseArray.count - 1) {
            cell.lblSaprator.isHidden = true
        } else {
            cell.lblSaprator.isHidden = false
        }
        if ExerciseArray[indexPath.row].favoriteStatus {
            cell.btnFev.setImage(#imageLiteral(resourceName: "fev_selected"), for: .normal)
        } else {
            cell.btnFev.setImage(#imageLiteral(resourceName: "fev_unlike"), for: .normal)
        }
        if isLoading {
            if indexPath.row == dataSource.count - 1 {
                apiListAllExercise(true, pageNo: pageNo)
            }
        }
        return cell
    }
}
//MARK:-Table View Delegates Methods
extension VideosVC: UITableViewDelegate {
    
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
//MARK:-Search Bar Delegates Methods
extension VideosVC: UISearchBarDelegate {
    
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
        apiListAllExercise(true, pageNo: 1)
//        ExerciseArray = dataSource
//        if ExerciseArray.count == 0 {
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
        apiListAllExercise(true, pageNo: 1)
        
//        guard !searchText.isEmpty else {
//            ExerciseArray = dataSource
//            if ExerciseArray.count == 0 {
//                tableView.isHidden = true
//            } else {
//                tableView.isHidden = false
//            }
//            tableView.reloadData()
//            return
//        }
//        ExerciseArray = dataSource.filter({ (data) -> Bool in
//            data.title.lowercased().contains(searchText.lowercased())
//        })
//        if ExerciseArray.count == 0 {
//            tableView.isHidden = true
//        } else {
//            tableView.isHidden = false
//        }
//        tableView.reloadData()
    }
}

//MARK:- Pull to refresh
extension VideosVC {
    
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        isLoading = true
        pageNo = 1
        apiListAllExercise(true, pageNo: 1)
    }
}

//MARK: API Call
extension VideosVC {
    func apiListAllExercise(_ isRefresh: Bool, pageNo: Int) {
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
                        //return
                    }
                    if pageNo == 1 {
                        self.dataSource.removeAll()
                        self.ExerciseArray.removeAll()
                        self.tableView.reloadData()
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        let data = try decoder.decode([ExerciseModel].self, from: jsonData)
                        self.dataSource.append(contentsOf: data)
                        self.ExerciseArray = self.dataSource
                        if isRefresh {
                            self.refreshControl.endRefreshing()
                        }
                        if self.ExerciseArray.count == 0 {
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
    
    //MARK:-  Api Favorite
    func apiFavorite(id: String, index: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
//                    for (i, data) in self.dataSource.enumerated() {
//                        if self.ExerciseArray[index].id == data.id {
//                            self.dataSource[i].favoriteStatus = !self.dataSource[i].favoriteStatus
//                        }
//                    }
                    self.ExerciseArray[index].favoriteStatus = !self.ExerciseArray[index].favoriteStatus
                    self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .fade)
                })
            }
        }
    }
}

//MARK: Table View Cell Class
class VideosTableCell: UITableViewCell {
    @IBOutlet weak var lblSaprator: UILabel!
    @IBOutlet weak var btnFev: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var videoImg: UIImageView!
    @IBOutlet weak var PlayButtonImg: UIImageView!
}
