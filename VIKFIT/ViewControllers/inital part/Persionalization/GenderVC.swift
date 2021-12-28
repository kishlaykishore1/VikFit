//
//  GenderVC.swift
//  VIKFIT
//

import UIKit

class GenderVC: UIViewController {
    @IBOutlet weak var progressSize: NSLayoutConstraint!
    @IBOutlet weak var lblWoman: UILabel!
    @IBOutlet weak var femaleView: UIControl!
    
    var isFromSetting = false
    var param: [String: Any] = [:]
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        progressSize.constant = (14.28 / 100) * self.view.width
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        
        let navLabel = UILabel()
        
        let navTitle = NSMutableAttributedString(string: Messages.txtStep1, attributes:[
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 13) as Any])
        
        navTitle.append(NSMutableAttributedString(string: "• 7", attributes:[
            NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 13) as Any,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1)]))
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
    }
    
}
//MARK:- Buttons Action
extension GenderVC {
    //Mark: Back Button Tap Action
    override func backBtnTapAction() {
        self.navigationController?.popViewController(animated: true)
    }
    //Mark: Gender Selection Button
    @IBAction func actionSelectGender(_ sender: UIView) {
        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "BirthDayVC") as! BirthDayVC
        if sender.tag == 1 {
          param["gender"] = "woman"
        } else {
            param["gender"] = "man"
        }
        aboutVC.param = param
        aboutVC.isFromSetting = isFromSetting
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    //Mark: Swipe Gesture function
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case .right:
                self.navigationController?.popViewController(animated: true)
            case .left: break
//                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "BirthDayVC") as! BirthDayVC
//                if sender.tag == 1 {
//                         param["gender"] = "woman"
//                       } else {
//                           param["gender"] = "man"
//                       }
//                       aboutVC.param = param
//                self.navigationController?.pushViewController(aboutVC, animated: true)
            default:
                break
            }
        }
    }
}
