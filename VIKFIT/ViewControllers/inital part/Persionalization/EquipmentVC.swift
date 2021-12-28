//
//  EquipmentVC.swift
//  VIKFIT
//

import UIKit

class EquipmentVC: UIViewController {
    @IBOutlet weak var lblWithoutEquepment: UILabel!
    @IBOutlet weak var lblWithEquepment: UILabel!
    @IBOutlet weak var ivWithoutEquepment: UIImageView!
    @IBOutlet weak var ivWithEquepment: UIImageView!
    @IBOutlet weak var withEqupmentView: DesignableButton!
    @IBOutlet weak var withoutEqupmentView: DesignableButton!
    @IBOutlet weak var progressSize: NSLayoutConstraint!
    
    var isFromSetting = false
    var isSelected = false
    var param: [String: Any] = [:]
    var material = "0"
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressSize.constant = self.view.width
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        
        let navLabel = UILabel()
        
        let navTitle = NSMutableAttributedString(string: Messages.txtStep7, attributes:[
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 13) as Any])
        
        navTitle.append(NSMutableAttributedString(string: "• 7", attributes:[
            NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 13) as Any,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1)]))
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
    }
}
//MARK:- Button Actions
extension EquipmentVC {
    //Mark: Back Button Action
    override func backBtnTapAction() {
        self.navigationController?.popViewController(animated: true)
    }
    //Mark: Select equipment Button Action
    @IBAction func actionSelectEquipment(_ sender: UIView) {
        isSelected = true
        if sender.tag == 1 {
            ivWithEquepment.image = #imageLiteral(resourceName: "check_black")
            ivWithoutEquepment.image = #imageLiteral(resourceName: "no-stopping")
            lblWithoutEquepment.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            lblWithEquepment.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            withEqupmentView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.8352941176, blue: 0.06274509804, alpha: 1)
            withoutEqupmentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            material = "1"
        } else {
            ivWithEquepment.image = #imageLiteral(resourceName: "check")
            ivWithoutEquepment.image = #imageLiteral(resourceName: "without_equpment")
            lblWithEquepment.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            lblWithoutEquepment.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            withEqupmentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            withoutEqupmentView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.8352941176, blue: 0.06274509804, alpha: 1)
            material = "0"
        }
        
    }
    //Mark: Generate Session Button Action
    @IBAction func actionGenerateSession(_ sender: UIButton) {
        if isSelected {
            goLoading()
        } else {
            Common.showAlertMessage(message: Messages.selectEquepment, alertType: .error)
        }
    }
    
    func goLoading() {
        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "LoadingVC") as! LoadingVC
        guard let getNav = UIApplication.topViewController()?.navigationController else {
            return
        }
        let rootNavView = UINavigationController(rootViewController: aboutVC)
        if #available(iOS 13.0, *) {
            aboutVC.isModalInPresentation = true
        }
       
        param["material"] = material
        param["device_token"] = UserDefaults.standard.string(forKey: "deviceToken") ?? "5ed812dbccb12ea9a7a98fae0527c9642efb581a11bb54995f9b8fa022e8aef4"
        aboutVC.param = param
        aboutVC.isFromSetting = isFromSetting
        getNav.present( rootNavView, animated: true, completion: nil)
    }
}
