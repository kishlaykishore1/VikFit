//
//  WodsTableTopCell.swift
//  VIKFIT
//

import UIKit
import SPStorkController
class WodsTableTopCell: UITableViewCell, EasyTipViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var lblDateAsTitle: UILabel!
    
    var wodsVC: WodsVC?
    var preferences = EasyTipView.Preferences()
    var tipView: EasyTipView?
    var dataSource = [ListDataArr]()
    var isFirst = false
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        //MARK:Tool Tip For The Top Buttons
        DispatchQueue.main.async {
            self.preferences.drawing.font = UIFont(name: "HelveticaNeue-Medium", size: 14)!
            self.preferences.drawing.foregroundColor = UIColor.white
            self.preferences.drawing.textAlignment = .left
            self.preferences.drawing.isGradient = true
            self.preferences.drawing.colorGradient = [#colorLiteral(red: 0.2588235294, green: 0.6901960784, blue: 1, alpha: 1) ,#colorLiteral(red: 0, green: 0.4274509804, blue: 0.9294117647, alpha: 1)]
            self.preferences.drawing.arrowHeight = 12
            self.preferences.drawing.arrowWidth = 20
            self.preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
            self.preferences.positioning.bubbleHInset = 16
            self.tipView = EasyTipView(text: "Discover more WOD for this week. 💪".localized, preferences: self.preferences, delegate: self)
            if !UserDefaults.standard.bool(forKey: "isToolTipHide") {
                self.tipView?.show(forView: self.btnPrevious, withinSuperview: self.topMostController()?.view)
            }
            
            var attributedHello = NSAttributedString(string: "Hello ".localized, attributes:  [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 25)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)] as [NSAttributedString.Key : Any])
            
            let attributedName = NSAttributedString(string: "\(UserModel.getUserModel()?.firstName ?? ""),", attributes:  [NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 25)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)] as [NSAttributedString.Key : Any])
            
            if (UserModel.getUserModel()?.firstName.trim() ?? "") == "" {
                attributedHello = NSAttributedString(string: "Hello".localized, attributes:  [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 25)!, NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)] as [NSAttributedString.Key : Any])
            }
            
            
            let txt = NSMutableAttributedString()
            txt.append(attributedHello)
            txt.append(attributedName)
            self.lblDateAsTitle.attributedText = txt
        }
    }
    //Mark: Action To Open Exercises
    @IBAction func actionOpenExcercise(_ sender: UIView) {
        wodsVC?.dismissTooltips()
        if UserModel.getUserModel() == nil {
            let loginVC = StoryBoard.Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let transitionDelegate = SPStorkTransitioningDelegate()
            loginVC.transitioningDelegate = transitionDelegate
            loginVC.modalPresentationStyle = .custom
            loginVC.modalPresentationCapturesStatusBarAppearance = true
            transitionDelegate.showIndicator = false
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            getNav.present(loginVC, animated: true, completion: nil)
            
        } else  {
            if dataSource[sender.tag].isUnloked ?? false {
                let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "WodPresentationVC") as! WodPresentationVC
                aboutVC.wodId = dataSource[sender.tag].id
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
            } else {
                checkUnlockWOD(index: sender.tag)
            }
        }
    }
    func checkUnlockWOD(index: Int) {
        guard  let userId = UserModel.getUserModel()?.id else {
            return
        }
        Global.showLoadingSpinner()
        var param = ["user_id": userId, "wod_id": dataSource[index].id, "type": "free"]
        if let receiptInfo = UserDefaults.standard.object(forKey: "ReceiptInfo") as? [String: Any] {
            param = ["transaction_id": receiptInfo["transaction_id"] as! String, "user_id": userId, "wod_id": dataSource[index].id, "type": receiptInfo["type"] as! String]
        }
        if param["type"] == "free" {
            Global.dismissLoadingSpinner()
            let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
            aboutVC.isFromHome = true
            aboutVC.param = param
            aboutVC.wodsVC = wodsVC
            guard let getNav = UIApplication.topViewController()?.navigationController else {
                return
            }
            let rootNavView = UINavigationController(rootViewController: aboutVC)
            rootNavView.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                getNav.isModalInPresentation = true
            }
            getNav.present( rootNavView, animated: true, completion: nil)
            return
        }
        if let getRequest = API.WODUNLOCK.request(method: .post, with: param, forJsonEncoding: true) {
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.WODUNLOCK.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let isUnlocked = jsonObject?["is_unloked"] as? Bool else {
                        return
                    }
                    
                    if isUnlocked {
                        self.wodsVC?.apiWorkOfDayData(false)
                        let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "WodPresentationVC") as! WodPresentationVC
                        aboutVC.wodId = self.dataSource[index].id
                        guard let getNav = UIApplication.topViewController()?.navigationController else {
                            return
                        }
                        let rootNavView = UINavigationController(rootViewController: aboutVC)
                        getNav.present( rootNavView, animated: true, completion: nil)
                    } else {
                        let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
                        aboutVC.isFromHome = true
                        guard let getNav = UIApplication.topViewController()?.navigationController else {
                            return
                        }
                        let rootNavView = UINavigationController(rootViewController: aboutVC)
                        rootNavView.modalPresentationStyle = .fullScreen
                        if #available(iOS 13.0, *) {
                            getNav.isModalInPresentation = true
                        }
                        getNav.present( rootNavView, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
}
//MARK:- Action For Buttons
extension WodsTableTopCell {
    //Mark: Next Button Action
    @IBAction func actionBtnNext(_ sender: UIButton) {
        wodsVC?.dismissTooltips()
        if dataSource.count > 0 {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            let indexPath = collectionView.indexPathsForVisibleItems.min()
            if (indexPath?.row ?? 0) > 0 {
                collectionView.scrollToPreviousItem()
            }
        }
        
    }
    //Mark: Function To set Button Image
    func setBtnImage(index: Int) {
        if index == 0 {
            btnPrevious.setImage(#imageLiteral(resourceName: "next"), for: .normal)
            btnNext.setImage(#imageLiteral(resourceName: "privious_disable"), for: .normal)
        }else if index == (dataSource.count - 1) {
            btnNext.setImage(#imageLiteral(resourceName: "previous"), for: .normal)
            btnPrevious.setImage(#imageLiteral(resourceName: "next_disable"), for: .normal)
        } else {
            btnNext.setImage(#imageLiteral(resourceName: "previous"), for: .normal)
            btnPrevious.setImage(#imageLiteral(resourceName: "next"), for: .normal)
        }
    }
    //Mark: Previous Button Action
    @IBAction func actionBtnPrevious(_ sender: UIButton) {
        wodsVC?.dismissTooltips()
        if dataSource.count > 0 {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            let indexPath = collectionView.indexPathsForVisibleItems.max()
            if (indexPath?.row ?? 0) < (dataSource.count - 1) {
                collectionView.scrollToNextItem()
            }
        }
    }
}
//MARK:- Collection View Delegates Methods
extension WodsTableTopCell: UICollectionViewDelegate {
    
}
//MARK:- Collection View DataSource Methods
extension WodsTableTopCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "WodsCollectionFirst", for: indexPath) as! WodsCollectionFirst
        cell.wodsVC = self.wodsVC
        cell.wodBackView.tag = indexPath.row
        //cell.lblDateAsTitle.text = dataSource[indexPath.row].dateOfWod
        cell.lblTille.text = dataSource[indexPath.row].nameOfWod
        cell.lblDuration.text = "\(dataSource[indexPath.row].totalDuration ?? "0")'"
        switch Int(dataSource[indexPath.row].difficulty ?? "0") {
        case 4:
            cell.lvl4.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            cell.lvl3.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            cell.lvl2.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            cell.lvl1.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            break
        case 3:
            cell.lvl4.backgroundColor = #colorLiteral(red: 0.5764705882, green: 0.5098039216, blue: 0, alpha: 0.34)
            cell.lvl3.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            cell.lvl2.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            cell.lvl1.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            break
        case 2:
            cell.lvl4.backgroundColor = #colorLiteral(red: 0.5764705882, green: 0.5098039216, blue: 0, alpha: 0.34)
            cell.lvl3.backgroundColor = #colorLiteral(red: 0.5764705882, green: 0.5098039216, blue: 0, alpha: 0.34)
            cell.lvl2.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            cell.lvl1.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
            break
        default:
            cell.lvl4.backgroundColor = #colorLiteral(red: 0.5764705882, green: 0.5098039216, blue: 0, alpha: 0.34)
            cell.lvl3.backgroundColor = #colorLiteral(red: 0.5764705882, green: 0.5098039216, blue: 0, alpha: 0.34)
            cell.lvl2.backgroundColor = #colorLiteral(red: 0.5764705882, green: 0.5098039216, blue: 0, alpha: 0.34)
            cell.lvl1.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.1803921569, blue: 0, alpha: 1)
        }
        if dataSource[indexPath.row].isUnloked ?? false {
            cell.imgWodLock.image = #imageLiteral(resourceName: "wod_unlock")
        } else {
            cell.imgWodLock.image = #imageLiteral(resourceName: "wod_lock")
        }
        if let url = URL(string: dataSource[indexPath.row].image ?? "") {
            cell.imgWOD.af_setImage(withURL: url)
        }
        
        //        if indexPath.row != (dataSource.count - 1) {
        //            DispatchQueue.main.async {
        //                cell.tipView1?.dismiss()
        //            }
        //        }
        if !(dataSource[indexPath.row].isFirst ?? false) {
            DispatchQueue.main.async {
                cell.tipView1?.dismiss()
            }
        }
        
        return cell
    }
}
//MARK:- Collection View DelegateFlowLayout Methods
extension WodsTableTopCell: UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        wodsVC?.dismissTooltips()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: collectionView.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        wodsVC?.dismissTooltips()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isPagingEnabled {
            setBtnImage(index: Int(scrollView.contentOffset.x / scrollView.bounds.size.width))
            
        }
    }
}
//MARK: Collection View Cell Class
class WodsCollectionFirst: UICollectionViewCell, EasyTipViewDelegate {
    
    @IBOutlet weak var lblTille: UILabel!
    //    @IBOutlet weak var lblSubText: UILabel!
    @IBOutlet weak var lblDef: UILabel!
    //    @IBOutlet weak var lblDateAsTitle: UILabel!
    @IBOutlet weak var lvl1: UILabel!
    @IBOutlet weak var lvl2: UILabel!
    @IBOutlet weak var lvl4: UILabel!
    @IBOutlet weak var imgWOD: UIImageView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lvl3: UILabel!
    @IBOutlet weak var wodBackView: DesignableButton!
    @IBOutlet weak var imgWodLock: UIImageView!
    
    var preferences = EasyTipView.Preferences()
    var tipView1: EasyTipView?
    var wodsVC: WodsVC?
    
    override func awakeFromNib() {
        //MARK: Tool Tip For UpperCollection View
        DispatchQueue.main.async {
            self.preferences.drawing.font = UIFont(name: "HelveticaNeue-Medium", size: 14)!
            self.preferences.drawing.foregroundColor = UIColor.white
            self.preferences.drawing.textAlignment = .left
            self.preferences.drawing.isGradient = true
            self.preferences.drawing.colorGradient = [#colorLiteral(red: 0.2588235294, green: 0.6901960784, blue: 1, alpha: 1) ,#colorLiteral(red: 0, green: 0.4274509804, blue: 0.9294117647, alpha: 1)]
            self.preferences.drawing.arrowHeight = 12
            self.preferences.drawing.arrowWidth = 20
            self.preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
            self.preferences.positioning.bubbleHInset = 36
            
            self.tipView1 = EasyTipView(text: "Every day a new WOD to train.".localized, preferences: self.preferences, delegate: self)
            if !UserDefaults.standard.bool(forKey: "isToolTipHide") {
                self.tipView1?.show(forView: self.lblDef, withinSuperview: self.topMostController()?.view)
            }
        }
    }
    //MARK: Tool Tip Dismiss Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        wodsVC?.dismissTooltips()
    }
}
