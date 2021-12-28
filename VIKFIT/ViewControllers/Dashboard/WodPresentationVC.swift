//
//  WodPresentationVC.swift
//  VIKFIT
//

import UIKit
import AlamofireImage
import WebKit

class WodPresentationVC: UIViewController {
    
    @IBOutlet weak var bttomView: UIView!
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDateOfWOD: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblTitleDiscp: UILabel!
    @IBOutlet weak var lblDescps: UILabel!
    @IBOutlet weak var lvl1: UILabel!
    @IBOutlet weak var lvl2: UILabel!
    @IBOutlet weak var lvl3: UILabel!
    @IBOutlet weak var lvl4: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    
    var wodId: String = ""
    var dataSource: WodDetailModal?
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        //webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        apiWODDetail()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        DispatchQueue.main.async {
            self.bttomView.roundCorners([.topLeft, .topRight], radius: 16)
        }
    }
}
//MARK:- Actions For Buttons
extension WodPresentationVC {
    //Mark: Back Button Pressed
    @IBAction func actionBtnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //Mark: Start Button Pressed
    @IBAction func btnStartWod(_ sender: UIButton) {
        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "StopWatchVC") as! StopWatchVC
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        getNav.present( rootNavView, animated: true, completion: nil)
    }
}
//MARK: API Call
extension WodPresentationVC {
    func apiWODDetail() {
        if let getRequest = API.WODDETAILS.request(method: .post, with: ["wod_id": wodId], forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.WODDETAILS.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.dataSource = try decoder.decode(WodDetailModal.self, from: jsonData)
                        self.setData()
                        
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
    
    func setData() {
        self.webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: self.dataSource?.linkDescription ?? "")!)
        self.webView.load(request)
        //lblDescps.text = dataSource?.descriptionWod ?? ""
        lblTitle.text = dataSource?.nameOfWod ?? ""
        lblDateOfWOD.text = "WOD of ".localized + "\(dataSource?.dateOfWod ?? "")"
//        lblTitleDiscp.text = dataSource?.titleDescription ?? ""
        lblDuration.text = "\(dataSource?.totalDuration ?? "0")'"
        switch Int(dataSource?.difficulty ?? "0") {
        case 4:
            lvl4.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            lvl3.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            lvl2.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            lvl1.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            break
        case 3:
            lvl4.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            lvl3.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            lvl2.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            lvl1.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            break
        case 2:
            lvl4.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            lvl3.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            lvl2.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            lvl1.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
            break
        default:
            lvl4.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            lvl3.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            lvl2.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            lvl1.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.3137254902, blue: 0, alpha: 1)
        }
        if let url = URL(string: dataSource?.image ?? "") {
            imgHeader.af_setImage(withURL: url)
        }
        
       // tableView.reloadData()
    }
}
//MARK: UIWebViewDelegate
extension WodPresentationVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Global.showLoadingSpinner()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Global.dismissLoadingSpinner()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Global.dismissLoadingSpinner()
        print(error)
    }
}

//MARK:-Table View Cell Class
class WodPresentationTableCell: UITableViewCell {
    @IBOutlet weak var lblTitleExe: UILabel!
//    @IBOutlet weak var lblRepeatation: UILabel!
    
}
