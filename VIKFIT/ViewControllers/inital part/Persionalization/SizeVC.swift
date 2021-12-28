//
//  SizeVC.swift
//  VIKFIT
//

import UIKit

class SizeVC: UIViewController {
    @IBOutlet weak var progressSize: NSLayoutConstraint!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var isFromSetting = false
    var param: [String: Any] = [:]
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        progressSize.constant = (14.28 * 4 / 100) * self.view.width
        self.navigationController?.isNavigationBarHidden = false
        setBackButton(tintColor: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), isImage: true)
        setNavigationBarImage(for: UIImage(), color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1))
        pickerView.setValue(UIColor.white, forKey: "magnifierLineColor")
        let navLabel = UILabel()
        
        let navTitle = NSMutableAttributedString(string: Messages.txtStep4, attributes:[
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 13) as Any])
        
        navTitle.append(NSMutableAttributedString(string: "• 7", attributes:[
            NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 13) as Any,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1)]))
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
        self.pickerView.selectRow(75, inComponent: 0, animated: true)
    }
}
//MARK:- Buttons Action
extension SizeVC {
    //Mark: Back button tap Action
    override func backBtnTapAction() {
        self.navigationController?.popViewController(animated: true)
    }
    //Mark: Next button tap Action
    @IBAction func actionNext(_ sender: UIButton) {
        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "WeightVC") as! WeightVC
        param["height"] = 250 - pickerView.selectedRow(inComponent: 0)
        aboutVC.param = param
        aboutVC.isFromSetting = isFromSetting
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
}
//MARK:- Size Picker DataSource Methods
extension SizeVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 200
        } else {
            return 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            return NSAttributedString(string: "\(250 - row)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        } else {
            return NSAttributedString(string: "cm".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        
    }
}
//MARK:- Size Picker Delegates Methods
extension SizeVC: UIPickerViewDelegate {
    
}
