//
//  BlogArticalsVC.swift
//  VIKFIT
//

import UIKit
import WebKit

class BlogArticalsVC: UIViewController {
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var lblPublishedDate: UILabel!
    @IBOutlet weak var lblPublisher: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var blogId = ""
    var dataSource: BlogModal?
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        apiGetBlogData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.bounces = false
    }
}
//MARK:- Button Actions
extension BlogArticalsVC {
    //Mark:- Back Button Action
    @IBAction func actionbtnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //Mark:- Share Button Action
    @IBAction func actionBtnShare(_ sender: UIButton) {
        let activityItem = CustomActivityItemProvider1(placeholderItem: "", titleOfBlog: dataSource?.title ?? "")
        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityViewController.setValue("⚡️ Check this post on VIKFIT".localized, forKey: "Subject")
        present(activityViewController, animated: true, completion: nil)
    }
}

extension BlogArticalsVC {
    func apiGetBlogData() {
        let param:[String: Any] = ["blog_id": blogId]
        if let getRequest = API.BLOGDETAIL.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.BLOGDETAIL.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.dataSource = try decoder.decode(BlogModal.self, from: jsonData)
                        self.webView.navigationDelegate = self
                        let request = URLRequest(url: URL(string: self.dataSource?.linkDescription ?? "")!)
                        self.webView.load(request)
                        self.lblPublisher.text = self.dataSource?.author ?? ""
                        self.lblTitle.text = self.dataSource?.title ?? ""
                        self.lblPublishedDate.text = self.dataSource?.datePublication ?? ""
                        if let url = URL(string: self.dataSource?.image ?? "") {
                            self.imgHeader.af_setImage(withURL: url)
                        }
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
}
//MARK: UIWebViewDelegate
extension BlogArticalsVC: WKNavigationDelegate {
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

