import UIKit
import Alamofire
import SystemConfiguration

open class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable     = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection) ? true : false
    }
}

enum API: String {
    var baseURL: String {
        #if DEBUG
        //return "http://app.vikfit.co/demo/"
        return "http://app.vikfit.co/"
        #else
        //return "http://app.vikfit.co/demo/"
        return "http://app.vikfit.co/"
        #endif
    }
    var apiURL: String {
        return "\(baseURL)api/"
    }
    var imageURL: String {
        return "\(baseURL)assets/uploads/users/"
    }
    
    /**
     When Update Api Version Please Update.
     - 'API_VERSION' on 'Constants.swift'
     */
    
    //  var encoding: ParameterEncoding {
    //    switch self {
    //    case .STATIC:
    //      return JSONEncoding.default
    //    default:
    //      return URLEncoding.default
    //    }
    //  }
    
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .STATIC:
            return .get
        default:
            return .post
        }
    }
    
    case STATIC                             = ""
    case LOGIN                              = "login"
    case SOCIAL                             = "social_login"
    case LOGINFB                            = "facebook"
    case LOGINGOOGLE                        = "google"
    case SKIPLOGIN                          = "skip_register"
    case REGISTER                           = "register"
    case UNIQUEEMAIL                        = "unique_email"
    case GENERALSETTING                     = "general_setting"
    case UPDATEPERSONALIZATION              = "update_personalized"
    case DASHBOARD                          = "dashboard"
    case LISTALL                            = "list_all"
    case FOLLOWERS                          = "followers"
    case FOLLOWINGS                         = "followings"
    case NOTIFICATIONLIST                   = "notifications_list"
    case NOTIFICATIONSEEN                   = "notifications_seen"
    case FAVORITELIST                       = "favorite_list"
    case FAVORITE                           = "favorite"
    case PROFILE                            = "profile"
    case FOLLOW                             = "follow"
    case UPDATEPROFILE                      = "update_profile"
    case GETFEEDS                           = "posts"
    case ADDFEED                            = "feed"
    case UPDATEFEED                         = "update_feed"
    case LIKEPOST                           = "post_likes"
    case REPORTONFEED                       = "post_report"
    case UNBLOCKALL                         = "unblock"
    case BLOCKUSER                          = "block"
    case OTHERUSERPROFILE                   = "other_user_profie"
    case GETFEEDDETAIL                      = "comments"
    case SENDCOMMENT                        = "post_comments"
    case BLOGDETAIL                         = "blog_details"
    case BUGREPORT                          = "bug_report"
    case LOGOUT                             = "logout"
    case DELETEACCOUNT                      = "close_account"
    case UNIQUEPHONE                        = "unique_phone"
    case PHONEUPDATE                        = "phone_update"
    case DELETEPOST                         = "post_delete"
    case WODDETAILS                         = "wod_details"
    case EXERCISEDETAIL                     = "exercise_details"
    case GETAD                              = "ads"
    case UPDATETOKEN                        = "device_token_update"
    case RATEWOD                            = "wod_ratings"
    case WODUNLOCK                          = "wod_unlocked"
    case WODPLANS                           = "wod_plans"
    case USERREPORT                         = "user_report"
    case UPDATEPROFILEPIC                   = "update_profile_pic"
    
    static let alamofireManager: SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 100
        return Alamofire.SessionManager(configuration: sessionConfiguration)
    }()
    
    func request(method: Alamofire.HTTPMethod = .post, with parameters: [String : Any]?, forJsonEncoding: Bool = false) -> Alamofire.DataRequest! {
        
        if !Reachability.isConnectedToNetwork() {
            Global.showAlert(withMessage:ConstantsMessages.kConnectionFailed)
            return nil
        } else {
            //            let manager = Alamofire.SessionManager.default
            //            manager.session.configuration.timeoutIntervalForRequest = 120
            // encoding: forJsonEncoding ? JSONEncoding.default : URLEncoding.default
            
            return API.alamofireManager.request(apiURL + self.rawValue, method: method, parameters: parameters, encoding: forJsonEncoding ? JSONEncoding.default : URLEncoding.default, headers: self.headerRequest())
            
            //        return API.alamofireManager.request(apiURL + self.rawValue, method: method, parameters: parameters, headers: nil)
        }
    }
    func requestRaw(with parameters: [String: Any]!) -> URLRequest{
        
        let posturl: URL? = URL(string:apiURL + self.rawValue)
        
        var request = URLRequest(url: posturl!)
        request.httpMethod = "Post"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters as Any, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        return request
    }
    
    
    func requestUpload(with parameters: [String: Any]? = nil, files: [String: Any]? = nil , completionHandler:((_ jsonObject: [String: Any]?, _ error: Error?) -> Void)?) {
        
        Alamofire.upload( multipartFormData: { multipartFormData in
            // Attach image
            if let files = files {
                for (key, value) in files {
                    if let getImage = value as? UIImage {
                        let imageData = getImage.jpegData(compressionQuality: 0.5)
                        multipartFormData.append(imageData!, withName: key, fileName: "\(key).jpg", mimeType: "image/jpg")
                        
                        print("\(key).jpg")
                    } else if let getAudioUrl = value as? Data {
                        
                        // multipartFormData.append(songData_ as Data, withName: "audio", fileName: songName, mimeType: "audio/m4a")
                        
                        multipartFormData.append(getAudioUrl, withName: key, fileName: "\(key).m4a", mimeType: "audio/m4a")
                    }
                }
            }
            
            for (key, value) in parameters ?? [:]  {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
        },to: apiURL + self.rawValue , method: .post , headers: self.headerRequest(),
        encodingCompletion: { encodingResult in
            
            self.validatedResponse(encodingResult, completionHandler: { (jsonObject, error) -> Void in
                completionHandler!(jsonObject, error )
            })
        })
    }
    
    func validatedResponse(_ response: DataResponse<Any>, completionHandler:((_ jsonObject: [String:Any]?, _ error:Error?) ->Void)?) {
        if let data = response.data {
            _ = String.init(data: data, encoding: String.Encoding.utf8)
        }
        
        switch response.result {
        
        case .success(let JSON):
            print("API NAME ********* \(self.rawValue)")
            print("Success with JSON: \(JSON)")
            let response = JSON as! [String:Any]
            
            let status = Global.getInt(for: response["status"] ?? 0)
            let getMessage = response["message"] as? String ?? ""
            // Successfully recieve response from server
            switch self {
            case .STATIC:
                completionHandler!(response, nil)
                
            default:
                
                if status == 1 { /*------- Success -----------*/
                    completionHandler!(response, nil)
                }else if status == 401 {  /*------- Records Not Found -----------*/
                    completionHandler!(nil, NSError(domain: Constants.kAppDisplayName, code: 204, userInfo:nil))
                    //Common.showAlertMessage(message: getMessage, alertType: .warning)
                }else {
                    completionHandler!(nil, NSError(domain: Constants.kAppDisplayName, code: 402, userInfo:nil))
                    Common.showAlertMessage(message: getMessage, alertType: .error)
                    //Global.showAlert(withMessage: getMessage)
                }
            //                }else if status == 401 { /*------- Session exipred -----------*/
            //                    // Constants.kAppDelegate.logout()
            //                    Global.showAlert(withMessage: getMessage)
            //                }else { /*----------Error Handling ------------------*/
            //                    //Server Error Error Handling......
            //                    if let message = response["response_message"] {
            //                        let messageStr = (message as! String)
            //                        let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.caseInsensitive])
            //                        let range = NSMakeRange(0, messageStr.count)
            //                        let htmlLessString :String = regex.stringByReplacingMatches(in: messageStr, options: [], range:range, withTemplate: "")
            //                        Global.showAlert(withMessage:htmlLessString as String)
            //                    }
            //                    completionHandler!(nil, NSError(domain: Constants.kAppDisplayName, code: 404, userInfo:nil))
            //                }
            }
            
        case .failure(let error):
            
            print("Request failed with error: \(error)")
            
            // recieve response from server
            switch self {
            case .STATIC:
                Global.showAlert(withMessage:ConstantsMessages.kSomethingWrong)
                completionHandler!(nil, error as NSError?)
            default:
                //let requestURLstring:String = (response.request?.URL?.description)!
                
                if let data = response.data {
                    Common.showAlertMessage(message: ConstantsMessages.kNetworkFailure, alertType: .error)
                    
                    let responceData = String(data: data, encoding:String.Encoding.utf8)!
                    print("**** SerializationFailed\n\(responceData) \n ****")
                    completionHandler!(nil, error as NSError?)
                } else {
                    Common.showAlertMessage(message: ConstantsMessages.kNetworkFailure, alertType: .error)
                    completionHandler!(nil, error as NSError?)
                }
            }
        }
    }
    
    func validatedResponse(_ response: SessionManager.MultipartFormDataEncodingResult, completionHandler:((_ jsonObject: [String: Any]?, _ error: Error?) ->Void)?) {
        
        switch response {
        case .success(let JSON,_,_):
            JSON.responseJSON { responseResult in
                print(responseResult)
                if responseResult.data != nil  {
                    print("Success with JSON: \(String(describing: String.init(data: responseResult.data!, encoding: String.Encoding.utf8)))")
                    _ = String.init(data: responseResult.data!, encoding: String.Encoding.utf8)
                }
                if responseResult.result.value == nil {
                    
                    completionHandler!(nil, NSError(domain: Constants.kAppDisplayName, code: 404, userInfo:nil))
                    //Global.showAlert(withMessage: ConstantsMessages.kConnectionFailed)
                    return ;
                }
                guard let response = responseResult.result.value as? [String: Any] else {
                    return  completionHandler!(nil, NSError(domain: Constants.kAppDisplayName, code: 404, userInfo:nil))
                }
                
                let status = Global.getInt(for: response["status"] ?? 0)
                let getMessage = response["message"] as? String ?? ""
                // Successfullu recieve response from server
                switch self {
                case .STATIC:
                    completionHandler!(response, nil)
                default:
                    
                    if status == 1 { /*------- Success -----------*/
                        completionHandler!(response, nil)
                    }else if status == 403 { /*------- Success -----------*/
                        // Constants.kAppDelegate.logout()
                        Global.showAlert(withMessage: getMessage)
                    } else { /*----------Error Handling ------------------*/
                        //Server Error Error Handling......
                        if let message = response["message"] {
                            let messageStr = (message as! String)
                            let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.caseInsensitive])
                            let range = NSMakeRange(0, messageStr.count)
                            let htmlLessString :String = regex.stringByReplacingMatches(in: messageStr, options: [], range:range, withTemplate: "")
                            
                            Common.showAlertMessage(message: htmlLessString as String, alertType: .error)
                        }
                        
                        completionHandler!(nil, NSError(domain: Constants.kAppDisplayName, code: 404, userInfo:nil))
                    }
                }
            }
        case .failure(let error):
            completionHandler!(nil, error as NSError?)
            
            Common.showAlertMessage(message: ConstantsMessages.kConnectionFailed, alertType: .error)
        }
    }
    
    /// Configure Headers
    
    private func headerRequest() -> [String : String] {        
        var headers = [String : String]()
        headers["lng"] = getLanguage()
        return headers//[:]
    }
}

