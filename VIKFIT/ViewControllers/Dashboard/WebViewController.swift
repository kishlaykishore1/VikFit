
import UIKit
import WebKit

class WebViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var webView: WKWebView!
    
    //MARK: Proparites
    public var url = ""
    public var flag = false
    var titleString = ""
    var welcomeVC: WelcomeVC?
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1))
        setBackButton(tintColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), isImage: true, #imageLiteral(resourceName: "back_button"))
        
        self.title = titleString
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), NSAttributedString.Key.kern: -0.41]
        
    }
    //MARK: BACK Button Tap Action
    override func backBtnTapAction() {
        if flag {
            self.dismiss(animated: true) {
                self.welcomeVC?.openLoginOptions()
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: UIWebViewDelegate
extension WebViewController: WKNavigationDelegate {
    
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
