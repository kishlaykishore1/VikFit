//
//  CongratesVC.swift
//  VIKFIT
//


import UIKit
import Cosmos

class CongratesVC: UIViewController {
    @IBOutlet weak var rateView: CosmosView!
    
    var wodId = ""
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rateView.didFinishTouchingCosmos = { rating in
            self.apiRate(rate: "\(Int(rating))")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
}

//MARK:- Button Actions
extension CongratesVC {
    //Mark:Back to Home Button Action
    @IBAction func actionBackToHome(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    //Mark:Share App Button Action
    @IBAction func actionShareApp(_ sender: UIButton) {
        let activityItem = CustomActivityItemProvider(placeholderItem: "")
        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityViewController.setValue(Messages.txtAppShareSubject, forKey: "Subject")
        present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK:-  Api Favorite
    func apiRate(rate: String) {
        guard let userId = UserModel.getUserModel()?.id else {
            return
        }
        let param:[String: Any] = ["user_id": userId, "wod_id": wodId, "rating": rate]
        print(param)
        if let getRequest = API.RATEWOD.request(method: .post, with: param, forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.RATEWOD.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                })
            }
        }
    }
}
