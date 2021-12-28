//
//  ExerciseVC.swift
//  VIKFIT


import UIKit
import AVFoundation

class ExerciseVC: UIViewController {
    
    @IBOutlet weak var lblExTitle: UILabel!
    @IBOutlet weak var topView: DesignableView!
    @IBOutlet weak var videoPlayView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnFev: UIButton!
    @IBOutlet weak var lblSubExe: UILabel!
    @IBOutlet weak var lblTips: UILabel!
    @IBOutlet weak var imgThumbnil: UIImageView!
    
    var player = AVPlayer()
    var exerciseID = ""
    var dataSource: ExerciseDetailModal?
    var playerLayer: AVPlayerLayer?
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apiExercizeDetail()
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        DispatchQueue.main.async {
            self.topView.roundCorners([.topLeft, .topRight], radius: 24)
        }
        
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//               if UIDevice.current.orientation.isLandscape {
//                   print("Landscape")
//                   imageView.image = UIImage(named: const2)
//               } else {
//                   print("Portrait")
//                   imageView.image = UIImage(named: const)
//               }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
         super.viewWillTransition(to: size, with: coordinator)
               if UIDevice.current.orientation.isLandscape {
                   print("Landscape")
                playerLayer?.videoGravity = .resizeAspectFill
               } else {
                   print("Portrait")
                playerLayer?.videoGravity = .resizeAspect
               }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.viewControllerOrientation = 1
//
//    }
    override func viewDidDisappear(_ animated: Bool) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.viewControllerOrientation = 0
        player.pause()
        self.playerLayer?.removeFromSuperlayer()
    }
    @objc func playerDidFinishPlaying(note: NSNotification) {
        player.seek(to: CMTime.zero)
    }
}
//MARK:- Button Actions
extension ExerciseVC {
    //Mark: Action For Tap On Video
    @IBAction func actionTapOnVideo(_ sender: UIControl) {
        btnPlay.isHidden = false
        player.pause()
    }
    
    //Mark: Action For Play Video
    @IBAction func actionPlayVideo(_ sender: UIButton) {
        btnPlay.isHidden = true
        player.play()
    }
    
    //Mark: Action For Back Button
    @IBAction func actionBtnBack(_ sender: UIButton) {
        self.player.pause()
        self.dismiss(animated: true, completion: nil)
    }
    //Mark: Action For Like Button
    @IBAction func btnActionLike(_ sender: UIButton) {
        apiFavorite()
    }
}
//MARK: API Call
extension ExerciseVC {
    
    //MARK:-  Api Favorite
    func apiFavorite() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "exercise_id": exerciseID]
        print(param)
        if let getRequest = API.FAVORITE.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.FAVORITE.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    self.apiExercizeDetail()
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                })
            }
        }
    }
    
    func apiExercizeDetail() {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        if let getRequest = API.EXERCISEDETAIL.request(method: .post, with: ["exercise_id": exerciseID, "user_id": userId], forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.EXERCISEDETAIL.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil, let getData = jsonObject?["data"] as? [String: Any] else {
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        self.dataSource = try decoder.decode(ExerciseDetailModal.self, from: jsonData)
                        self.setDataAccordingIndex()
                    } catch let err {
                        print("Err", err)
                    }
                })
            }
        }
    }
    
    func setDataAccordingIndex() {
        lblTips.text = dataSource?.coachTip
        lblSubExe.text = dataSource?.title
        lblExTitle.text = dataSource?.exercise
        if let url = URL(string: dataSource?.thumbURL ?? "") {
            imgThumbnil.af_setImage(withURL: url)
        }
        (dataSource?.favoriteStatus ?? false) ? btnFev.setImage(#imageLiteral(resourceName: "like_white_background"), for: .normal) : btnFev.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        guard let url = URL(string: dataSource?.videoLink ?? "") else {
            debugPrint("video not found")
            return
        }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = videoPlayView.frame
        videoPlayView.layer.addSublayer(playerLayer!)
        self.player.play()
    }
}
