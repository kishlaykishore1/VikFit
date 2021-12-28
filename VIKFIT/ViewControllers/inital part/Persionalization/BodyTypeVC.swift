//
//  BodyTypeVC.swift
//  VIKFIT
//

import UIKit

class BodyTypeVC: UIViewController {
    
    @IBOutlet weak var progressSize: NSLayoutConstraint!
    var isFromSetting = false
    var param: [String: Any] = [:]
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        progressSize.constant = (14.28 * 3 / 100) * self.view.width
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        
        let navLabel = UILabel()
        
        let navTitle = NSMutableAttributedString(string: Messages.txtStep3, attributes:[
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 13) as Any])
        
        navTitle.append(NSMutableAttributedString(string: "• 7", attributes:[
            NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 13) as Any,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1)]))
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
    }
    
}
//MARK:-Buttons Action
extension BodyTypeVC {
    //Mark: back button tap Action
    override func backBtnTapAction() {
        self.navigationController?.popViewController(animated: true)
    }
    //Mark: Select Body Type Action
    @IBAction func actionSelectBodyType(_ sender: UIButton) {
        
        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "SizeVC") as! SizeVC
        switch sender.tag {
        case 1:
            param["body_type"] = "skinny"
            break
        case 2:
            param["body_type"] = "fat"
            break
        default:
            param["body_type"] = "normal"
            break
        }
        aboutVC.param = param
        aboutVC.isFromSetting = isFromSetting
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
}
