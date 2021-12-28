//
//  UITextfield.swift
//

import UIKit.UITextField
private var __maxLengths = [UITextField: Int]()
extension UITextField {
    
    /// set icon of 20x20 with left padding of 8px
    func setLeftMargin(_ icon: UIImage? = nil, padding: Int = 8) {

        let size = 0
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size + padding, height: size) )
        if let icon = icon {
         let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: 20, height: 20))
        iconView.contentMode = .scaleAspectFit
         iconView.image = icon
         outerView.addSubview(iconView)
        }
        leftView = outerView
        leftViewMode = .always
    }
}

extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension String
{
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}
