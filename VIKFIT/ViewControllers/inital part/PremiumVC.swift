//
//  PremiumVC.swift
//  VIKFIT
//


import UIKit
import StoreKit

class PremiumVC: UIViewController {
    @IBOutlet weak var view6Months: UIView!
    @IBOutlet weak var lbl6Months: UILabel!
    @IBOutlet weak var lblMonths: UILabel!
    @IBOutlet weak var viewWeek: UIView!
    @IBOutlet weak var lblWeek: UILabel!
    @IBOutlet weak var viewMOnths: UIView!
    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var lblPrice1: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var lblDiscription1: UILabel!
    @IBOutlet weak var lblPricePerSession1: UILabel!
    @IBOutlet weak var lblDescription2: UILabel!
    @IBOutlet weak var lblPrice2: UILabel!
    @IBOutlet weak var lblPricePerSession2: UILabel!
    @IBOutlet weak var lblTermsNService: TTTAttributedLabel!
    
    //MARK: Properties
    var isFromSetting = false
    var isFromHome = false
    var viewModel = ViewModel()
    var currentTab = 103
    var param:[String: Any] = [:]
    var wodsVC: WodsVC?
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.viewDidSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        Global.showLoadingSpinner()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            Global.dismissLoadingSpinner()
            self.selectedTabData(index: self.currentTab)
        }
    }
}
//MARK:-Button Actions
extension PremiumVC {
    //Mark: Cross Button Action
    @IBAction func actionBtnCross(_ sender: UIButton) {
        
        if isFromHome {
            self.dismiss(animated: true, completion: nil)
        } else {
            if #available(iOS 13.0, *) {
                let scene = UIApplication.shared.connectedScenes.first
                if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    sd.isUserLogin(true)
                }
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.isUserLogin(true)
            }
        }
        
        //        if isFromSetting {
        //            self.view.window!.rootViewController?.dismiss(animated: true, completion: {
        //                let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        //                if #available(iOS 13.0, *) {
        //                    aboutVC.isModalInPresentation = true
        //                }
        //                guard let getNav = UIApplication.topViewController()?.navigationController else {
        //                    return
        //                }
        //
        //                let rootNavView = UINavigationController(rootViewController: aboutVC)
        //                getNav.present( rootNavView, animated: true, completion: nil)
        //            })
        //        } else {
        //            if isFromHome {
        //                self.dismiss(animated: true, completion: nil)
        //            } else {
        //                if #available(iOS 13.0, *) {
        //                    let scene = UIApplication.shared.connectedScenes.first
        //                    if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
        //                        sd.isUserLogin(true)
        //                    }
        //                } else {
        //                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //                    appDelegate.isUserLogin(true)
        //                }
        //            }
        //        }
    }
    
    //Mark: Select Membership Plans Button Action
    @IBAction func actionSelectPlan(_ sender: UIView) {
        var selectedProduct: Int?
        IAPManager.shared.startObserving()
        Global.showLoadingSpinner()
        switch self.currentTab {
        case 101:
            if sender.tag == 1 {
                selectedProduct = 0
            } else if sender.tag == 2 {
                selectedProduct = 1
            } else {
                moveToHome()
            }
            break
        case 102:
            if sender.tag == 1 {
                selectedProduct = 2
            } else if sender.tag == 2 {
                selectedProduct = 3
            } else {
                moveToHome()
            }
            break
            
        default:
            if sender.tag == 1 {
                selectedProduct = 4
            } else if sender.tag == 2 {
                selectedProduct = 5
            } else {
                moveToHome()
            }
            break
        }
        guard (selectedProduct != nil) else {
            //showSingleAlert(withMessage: "Purchasing/Renewing this item is not possible at the moment.")
            return
        }
        guard let product = viewModel.getProductForItem(at: selectedProduct!) else {
            showSingleAlert(withMessage: "Purchasing/Renewing this item is not possible at the moment.".localized)
            Global.dismissLoadingSpinner()
            return
        }
        //showAlert(for: product)
        
        if !self.viewModel.purchase(product: product) {
            self.showSingleAlert(withMessage: "In-App Purchases are not allowed in this device.".localized)
        }
        
    }
    func moveToHome() {
        if param.isEmpty {
            if #available(iOS 13.0, *) {
                let scene = UIApplication.shared.connectedScenes.first
                if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    sd.isUserLogin(true)
                }
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.isUserLogin(true)
            }
        } else {
            checkUnlockWOD()
        }
    }
    
    //Mark: Tap Action on Week
    @IBAction func actionOnTap(_ sender: UIView) {
        print(sender.tag)
        currentTab = sender.tag
        self.selectedTabData(index: sender.tag)
        switch sender.tag {
        case 101:
            lblWeek.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            viewWeek.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            lblMonths.textColor = #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1)
            viewMOnths.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 0)
            lbl6Months.textColor = #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1)
            view6Months.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 0)
            break
        case 102:
            lblWeek.textColor = #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1)
            viewWeek.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 0)
            lblMonths.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            viewMOnths.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            lbl6Months.textColor = #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1)
            view6Months.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 0)
            break
        default:
            lblWeek.textColor = #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1)
            viewWeek.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 0)
            lblMonths.textColor = #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1)
            viewMOnths.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 0)
            lbl6Months.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            view6Months.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            break
        }
    }
}
//MARK: TermsOfUse Label Set
extension PremiumVC {
    func setup() {
        lblTermsNService.numberOfLines = 0;
        
        let strPP = Messages.txtPPNewsFeed
        let strTC = Messages.txtTermsOfUse
        let string = "\(Messages.txtPrimiumMes)\n\(Messages.txtPrimiumMes1)\n\(Messages.txtPrimiumMes2) \(strTC) \(Messages.txtPrimiumMes3) \(strPP)."
        
        let nsString = string as NSString
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        
        let fullAttributedString = NSAttributedString(string:string, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            NSAttributedString.Key.font: UIFont.init(name: "Poppins-Regular", size: 10) ?? UIFont()
        ])
        
        lblTermsNService.textAlignment = .center
        lblTermsNService.attributedText = fullAttributedString
        
        let rangeTC = nsString.range(of: strTC)
        let rangePP = nsString.range(of: strPP)
        
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: #colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1),
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue: UIFont.init(name: "Poppins-Bold", size: 10) ?? UIFont()
        ]
        
        lblTermsNService.activeLinkAttributes = ppLinkAttributes
        lblTermsNService.linkAttributes = ppLinkAttributes
        
        let urlTC = URL(string: "action://TC")!
        let urlPP = URL(string: "action://PP")!
        lblTermsNService.addLink(to: urlTC, with: rangeTC)
        lblTermsNService.addLink(to: urlPP, with: rangePP)
        
        lblTermsNService.textColor = #colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1)
        lblTermsNService.delegate = self
    }
}

//MARK: TTTAttributedLabelDelegate
extension PremiumVC: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "action://TC" {
            
            let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.titleString = Messages.txtSec5TermService
            webViewController.url = Constants.kAppDelegate.generalSettingsModal?.terms ?? ""
            navigationController?.pushViewController(webViewController, animated: true)
            
            //            guard let url = URL(string: Constants.kAppDelegate.generalSettingsModal?.terms ?? "") else { return }
            //            UIApplication.shared.open(url)
        } else {
            
            let webViewController: WebViewController = StoryBoard.Home.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.titleString = Messages.txtSec5PrivacyPolicy
            webViewController.url = Constants.kAppDelegate.generalSettingsModal?.privacy ?? ""
            navigationController?.pushViewController(webViewController, animated: true)
            
            //            guard let url = URL(string: Constants.kAppDelegate.generalSettingsModal?.privacy ?? "") else { return }
            //            UIApplication.shared.open(url)
        }
        
    }
}


extension PremiumVC {
    
    func selectedTabData(index: Int) {
        switch index {
        case 101:
            guard let product1 = viewModel.getProductForItem(at: 0) else {return}
            guard let price1 = IAPManager.shared.getPriceFormatted(for: product1) else { return }
            guard let pricePerSession1 = IAPManager.shared.getOneSessionPriceFormatted(for: Double(truncating: product1.price) / 3, for: product1) else { return }
            lblPrice1.text = "\(price1) / " + "week".localized
            lblPricePerSession1.text = "\(pricePerSession1) " + "per session".localized
            
            guard let product2 = viewModel.getProductForItem(at: 1) else {return}
            guard let price2 = IAPManager.shared.getPriceFormatted(for: product2) else { return }
            guard let pricePerSession2 = IAPManager.shared.getOneSessionPriceFormatted(for: Double(truncating: product2.price) / 5, for: product2) else { return }
            lblPrice2.text = "\(price2) / " + "week".localized
            lblPricePerSession2.text = "\(pricePerSession2) " + "per session".localized
            break
        case 102:
            guard let product1 = viewModel.getProductForItem(at: 2) else {return}
            guard let price1 = IAPManager.shared.getPriceFormatted(for: product1) else { return }
            guard let pricePerSession1 = IAPManager.shared.getOneSessionPriceFormatted(for: Double(truncating: product1.price) / 36, for: product1) else { return }
            lblPrice1.text = "\(price1) / 3 " + "months".localized
            lblPricePerSession1.text = "\(pricePerSession1) " + "per session".localized
            
            guard let product2 = viewModel.getProductForItem(at: 3) else {return}
            guard let price2 = IAPManager.shared.getPriceFormatted(for: product2) else { return }
            guard let pricePerSession2 = IAPManager.shared.getOneSessionPriceFormatted(for: Double(truncating: product2.price) / 60, for: product2) else { return }
            lblPrice2.text = "\(price2) / 3 " + "months".localized
            lblPricePerSession2.text = "\(pricePerSession2) " + "per session".localized
            break
        default:
            guard let product1 = viewModel.getProductForItem(at: 4) else {return}
            guard let price1 = IAPManager.shared.getPriceFormatted(for: product1) else { return }
            guard let pricePerSession1 = IAPManager.shared.getOneSessionPriceFormatted(for: Double(truncating: product1.price) / 72, for: product1) else { return }
            lblPrice1.text = "\(price1) / 6 " + "months".localized
            lblPricePerSession1.text = "\(pricePerSession1) " + "per session".localized
            
            guard let product2 = viewModel.getProductForItem(at: 5) else {return}
            guard let price2 = IAPManager.shared.getPriceFormatted(for: product2) else { return }
            guard let pricePerSession2 = IAPManager.shared.getOneSessionPriceFormatted(for: Double(truncating: product2.price) / 120, for: product2) else { return }
            lblPrice2.text = "\(price2) / 6 " + "months".localized
            lblPricePerSession2.text = "\(pricePerSession2) " + "per session".localized
            break
        }
    }
    
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
    }
    
    @IBAction func restorePurchases(_ sender: UIButton) {
        IAPManager.shared.startObserving()
        viewModel.restorePurchases()
    }
    // MARK: - Methods To Implement
    //    func showAlert(for product: SKProduct) {
    //                guard let price = IAPManager.shared.getPriceFormatted(for: product) else { return }
    //                let alertController = UIAlertController(title: product.localizedTitle,
    //                                                        message: product.localizedDescription,
    //                                                        preferredStyle: .alert)
    //
    //                alertController.addAction(UIAlertAction(title: "Buy now for \(price)", style: .default, handler: { (_) in
    //                    if !self.viewModel.purchase(product: product) {
    //                        self.showSingleAlert(withMessage: "In-App Purchases are not allowed in this device.")
    //                    }
    //                }))
    //
    //                alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (_) in
    //                    Global.dismissLoadingSpinner()
    //                }))
    //                self.present(alertController, animated: true, completion: nil)
    //    }
    
    func showSingleAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "VIKFIT", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (_) in
            Global.dismissLoadingSpinner()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: "There are no purchased items to restore.".localized)
    }
    
    func didFinishRestoringPurchasedProducts() {
        showSingleAlert(withMessage: "All previous In-App Purchases have been restored!".localized)
    }
}


extension PremiumVC {
    func checkUnlockWOD() {
        if let getRequest = API.WODUNLOCK.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.WODUNLOCK.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let isUnlocked = jsonObject?["is_unloked"] as? Bool else {
                        return
                    }
                    
                    if isUnlocked {
                        self.dismiss(animated: true) {
                            self.wodsVC?.viewDidLoad()
                            let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "WodPresentationVC") as! WodPresentationVC
                            aboutVC.wodId = self.param["wod_id"] as! String
                            guard let getNav = UIApplication.topViewController()?.navigationController else {
                                return
                            }
                            let rootNavView = UINavigationController(rootViewController: aboutVC)
                            getNav.present( rootNavView, animated: true, completion: nil)
                        }
                    } else {
                        Common.showAlertMessage(message: "You already get your free WOD for this week.".localized, alertType: .warning)
                        Global.dismissLoadingSpinner()
                    }
                })
            }
        }
    }
}
