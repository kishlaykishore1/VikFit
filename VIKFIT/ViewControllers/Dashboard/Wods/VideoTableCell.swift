//
//  VideoTableCell.swift
//  VIKFIT
//

import Foundation
import UIKit
import AlamofireImage
import SPStorkController

//MARK:- TableView Cell Class
class VideoTableCell: UITableViewCell {
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnAllExercise: UIButton!
    
    var wodsVC: WodsVC?
    var dataSource = [ListDataArr]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

//MARK:- Collection View Delegates Methods
extension VideoTableCell: UICollectionViewDelegate {
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
//            guard let receiptInfo = UserDefaults.standard.object(forKey: "ReceiptInfo") as? [String: Any] else {
//                Common.showAlertMessage(message: Messages.mustSubscribe, alertType: .warning)
//                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
//                aboutVC.isFromHome = true
//                guard let getNav = UIApplication.topViewController()?.navigationController else {
//                    return
//                }
//                let rootNavView = UINavigationController(rootViewController: aboutVC)
//                rootNavView.modalPresentationStyle = .fullScreen
//                if #available(iOS 13.0, *) {
//                    getNav.isModalInPresentation = true
//                }
//                getNav.present( rootNavView, animated: true, completion: nil)
//                return
//            }
//            if receiptInfo["type"] as! String == "premium" {
                collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: true)
                let aboutVC = StoryBoard.Home.instantiateViewController(withIdentifier: "ExerciseVC") as! ExerciseVC
                aboutVC.exerciseID = dataSource[indexPath.row].id
                guard let getNav = UIApplication.topViewController()?.navigationController else {
                    return
                }
                let rootNavView = UINavigationController(rootViewController: aboutVC)
                rootNavView.modalPresentationStyle = .fullScreen
                getNav.present( rootNavView, animated: true, completion: nil)
                
//            } else {
//                let aboutVC = StoryBoard.Main.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
//                aboutVC.isFromHome = true
//                guard let getNav = UIApplication.topViewController()?.navigationController else {
//                    return
//                }
//                let rootNavView = UINavigationController(rootViewController: aboutVC)
//                rootNavView.modalPresentationStyle = .fullScreen
//                if #available(iOS 13.0, *) {
//                    getNav.isModalInPresentation = true
//                }
//                getNav.present( rootNavView, animated: true, completion: nil)
//            }
        }
    }
}

//MARK: Collection View DataSource Methods
extension VideoTableCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "WodsCollectionVideo", for: indexPath) as! WodsCollectionVideo
        cell.lblExeciseName.text = dataSource[indexPath.row].exercise
        cell.lblTypeName.text = dataSource[indexPath.row].title
        cell.imgLock.image = #imageLiteral(resourceName: "lock_exe")
//        if let receiptInfo = UserDefaults.standard.object(forKey: "ReceiptInfo") as? [String: Any] {
//            if receiptInfo["type"] as! String == "premium" {
//                cell.imgLock.isHidden = true
//            } else {
//                cell.imgLock.isHidden = false
//            }
//        } else {
            cell.imgLock.isHidden = true
//        }
        if let url = URL(string: dataSource[indexPath.row].thumbURL ?? "") {
            cell.imgVideo.af_setImage(withURL: url)
        }
        return cell
    }
}

//MARK: Collection View DelegateFlowLayout Methods
extension VideoTableCell: UICollectionViewDelegateFlowLayout {
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

//MARK:- Collection View Cell class
class WodsCollectionVideo: UICollectionViewCell {
    @IBOutlet weak var lblTypeName: UILabel!
    @IBOutlet weak var lblExeciseName: UILabel!
    @IBOutlet weak var imgVideo: UIImageView!
    @IBOutlet weak var imgLock: UIImageView!
}

//MARK: Collection View scrolling Adjustment Functions
extension UICollectionView {
    
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}
