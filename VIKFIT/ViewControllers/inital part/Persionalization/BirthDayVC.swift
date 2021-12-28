//
//  BirthDayVC.swift
//  VIKFIT
//

import UIKit

class BirthDayVC: UIViewController {
    @IBOutlet weak var progressSize: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    var isFromSetting = false
    var param: [String: Any] = [:]
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())
        datePicker.locale = Locale.init(identifier: getLanguage())
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        
        progressSize.constant = (14.28 * 2 / 100) * self.view.width
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        if #available(iOS 14.0, *) {
            datePicker.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            datePicker.isHighlighted = false
        } else {
            if #available(iOS 13.0, *) {
                datePicker.setValue(UIColor.white, forKey: "magnifierLineColor")
                datePicker.setValue(false, forKeyPath: "highlightsToday")
            }
        }
        
        //        else {
        //            datePicker.subviews[0].subviews[1].backgroundColor = .white
        //            datePicker.subviews[0].subviews[2].backgroundColor = .white
        //        }
        let navLabel = UILabel()
        
        let navTitle = NSMutableAttributedString(string: Messages.txtStep2, attributes:[
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
extension BirthDayVC {
    //Mark: back button tap Action
    override func backBtnTapAction() {
        self.navigationController?.popViewController(animated: true)
    }
    //Mark: Button Next Action
    @IBAction func actionNext(_ sender: UIButton) {
        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "BodyTypeVC") as! BodyTypeVC
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        param["dob"] = dateFormatter.string(from: datePicker.date)
        aboutVC.param = param
        aboutVC.isFromSetting = isFromSetting
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
}
