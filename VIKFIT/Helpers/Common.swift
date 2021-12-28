 
import UIKit
import Foundation
import SwiftMessages
 
 enum MessageType {
    case warning
    case error
    case success
 }
 
class Common: NSObject {
    class func showAlertMessage(message: String, alertType: MessageType = .error)
    {
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue))
        config.interactiveHide = true
        config.preferredStatusBarStyle = .lightContent
        let messageView = MessageView.viewFromNib(layout: .messageView)
        
        switch alertType {
        case .error:
            messageView.configureTheme(.error)
            messageView.configureContent(title: Messages.txtError, body: message)
            messageView.button?.isHidden = true
            SwiftMessages.show(config: config, view: messageView)
        case .warning:
            messageView.configureTheme(.warning)
            messageView.configureContent(title: Messages.txtAlertMes, body: message)
            messageView.button?.isHidden = true
            SwiftMessages.show(config: config, view: messageView)
        case .success:
            messageView.configureTheme(.success)
            messageView.configureContent(title: Messages.txtSuccess, body: message)
            messageView.button?.isHidden = true
            SwiftMessages.show(config: config, view: messageView)
        }
    } 
}
