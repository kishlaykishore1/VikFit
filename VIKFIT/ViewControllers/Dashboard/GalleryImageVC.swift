
import UIKit
import AlamofireImage

class GalleryImageVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var zoomImageView: UIImageView!
    
    //MARK: Properties
    var imgStr = ""
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton(tintColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), isImage: true, #imageLiteral(resourceName: "left_back"))
        self.navigationController?.isNavigationBarHidden = false
        configureNavigationBar()
        if let url = URL(string: imgStr) {
        zoomImageView.af_setImage(withURL: url)
        }
    }
}
//MARK:-Actions For Buttons
extension GalleryImageVC {
    override func backBtnTapAction() {
        self.dismiss(animated: true, completion: nil)
    }
    //Mark: Zoom Image Action
    @IBAction func scaleImage(_ sender: UIPinchGestureRecognizer) {
        zoomImageView.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
    }
    
    func configureNavigationBar() {
        self.setNavigationBarImage(for: UIImage(), color: .clear)
    }
}
