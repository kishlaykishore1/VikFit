//
//  ActivityTableCell.swift
//  VIKFIT
//

import UIKit
import SPStorkController

class ActivityTableCell: UITableViewCell {
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnBlog: UIButton!
    
    var dataSource = [ListDataArr]()
    var wodsVC: WodsVC?
    var isNutrition: Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
//MARK:- CollectionView Delegate Methods
extension ActivityTableCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        wodsVC?.dismissTooltips()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
            if isNutrition ?? false {
//                guard let receiptInfo = UserDefaults.standard.object(forKey: "ReceiptInfo") as? [String: Any] else {
//                    Common.showAlertMessage(message: Messages.mustSubscribe, alertType: .warning)
//                    let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
//                    aboutVC.isFromHome = true
//                    guard let getNav = UIApplication.topViewController()?.navigationController else {
//                        return
//                    }
//                    let rootNavView = UINavigationController(rootViewController: aboutVC)
//                    rootNavView.modalPresentationStyle = .fullScreen
//                    if #available(iOS 13.0, *) {
//                        getNav.isModalInPresentation = true
//                    }
//                    getNav.present( rootNavView, animated: true, completion: nil)
//                    return
//                }
//                if receiptInfo["type"] as! String == "premium" {
                    collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: true)
                    let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "BlogArticalsVC") as! BlogArticalsVC
                    aboutVC.blogId = dataSource[indexPath.row].id
                    guard let getNav = UIApplication.topViewController()?.navigationController else {
                        return
                    }
                    let rootNavView = UINavigationController(rootViewController: aboutVC)
                    getNav.present( rootNavView, animated: true, completion: nil)
//                } else {
//                    let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
//                    aboutVC.isFromHome = true
//                    guard let getNav = UIApplication.topViewController()?.navigationController else {
//                        return
//                    }
//                    let rootNavView = UINavigationController(rootViewController: aboutVC)
//                    rootNavView.modalPresentationStyle = .fullScreen
//                    if #available(iOS 13.0, *) {
//                        getNav.isModalInPresentation = true
//                    }
//                    getNav.present( rootNavView, animated: true, completion: nil)
//                }
            } else {
                collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: true)
                let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "BlogArticalsVC") as! BlogArticalsVC
                aboutVC.blogId = dataSource[indexPath.row].id
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                getNav.present( rootNavView, animated: true, completion: nil)
            }
        }
    }
}
//MARK:- CollectionView DataSource Methods
extension ActivityTableCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "WodsCollectionAcivity", for: indexPath) as! WodsCollectionAcivity
        cell.lblTitle.text = dataSource[indexPath.row].title
        cell.imgLock.image = #imageLiteral(resourceName: "lock_nitri")
//        if isNutrition ?? false {
//            if let receiptInfo = UserDefaults.standard.object(forKey: "ReceiptInfo") as? [String: Any] {
//                if receiptInfo["type"] as! String == "premium" {
//                    cell.imgLock.isHidden = true
//                } else {
//                    cell.imgLock.isHidden = false
//                }
//
//            } else {
//                cell.imgLock.isHidden = false
//            }
//        } else {
            cell.imgLock.isHidden = true
//        }
        
        
        
        cell.lblDateTime.text = "Published".localized + " " + dataSource[indexPath.row].datePublication!
        return cell
    }
}
//MARK:- CollectionView DelegateFlowLayout Methods
extension ActivityTableCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width / 1.5, height: collectionView.height)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        wodsVC?.dismissTooltips()
        targetContentOffset.pointee.x = scrollView.contentOffset.x
        let pageWidth = scrollView.frame.width
        
        let newPageWidth : CGFloat = (pageWidth / 1.50)
        var assistanceOffset : CGFloat = (pageWidth / 1.50)
        
        if velocity.x < 0 {
            assistanceOffset = -assistanceOffset
        }
        
        print(assistanceOffset)
        
        let assistedScrollPosition = (scrollView.contentOffset.x) / newPageWidth
        
        var targetIndex = Int(round(assistedScrollPosition))
        if targetIndex < 0 {
            targetIndex = 0
        }
        else if targetIndex >= collectionView.numberOfItems(inSection: 0) {
            targetIndex = collectionView.numberOfItems(inSection: 0) - 1
        }
        let indexPath = NSIndexPath(item: targetIndex, section: 0)
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: true)
    }
}
//MARK:-Collection View Cell Class
class WodsCollectionAcivity: UICollectionViewCell {
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgLock: UIImageView!
}
