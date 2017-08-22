//
//  ReceiverTextField.swift
//  FileMail
//
//  Created by jiangkelan on 10/07/2017.
//  Copyright © 2017 xlvip. All rights reserved.
//

import UIKit

public enum ReceiverTextFieldState: Int {
    case normal; case error; case quering; case selected; case editing
}

public class ReceiverTextField: UITextField {
    
    var nextHandler: (() -> Void)?
    var textDidChanged: ((ReceiverTextField) -> Void)?
    var endEditingHandler: ((ReceiverTextField) -> Void)?
    var shouldBeginEditing: ((ReceiverTextField) -> Bool)?
    var reachEmptyDeleting: ((ReceiverTextField) -> Void)?
    
    var borderColorForState: ((ReceiverTextFieldState) -> UIColor?)?
    var backgroundColorForState: ((ReceiverTextFieldState) -> UIColor?)?
    var textColorForState: ((ReceiverTextFieldState) -> UIColor?)?
    
    var originalWidth: CGFloat = 0
    var textEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 8)
    
    var displayState: ReceiverTextFieldState = .normal {
        didSet { configDisplayState() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.leftView = {
            let width = frame.size.height - 6
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width + 5, height: width))
            
            let indicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: 0, width: width, height: width))
            view.addSubview(indicator)
            
            indicator.startAnimating()
            return view
        }()
        
        self.borderStyle = .none
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = frame.size.height / 2
        
        self.returnKeyType = .next
        self.delegate = self
        
        self.addTarget(self, action: #selector(textFielDidChanged(_:)), for: .editingChanged)
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.origin.x += self.textEdgeInsets.left
        rect.size.width -= (self.textEdgeInsets.left + self.textEdgeInsets.right)
        return rect
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect.origin.x += self.textEdgeInsets.left
        rect.size.width -= (self.textEdgeInsets.left + self.textEdgeInsets.right)
        return rect
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configDisplayState() -> Void {
        let borderColor: UIColor = borderColorForState?(displayState) ?? .clear
        let backgroundColor: UIColor = backgroundColorForState?(displayState) ?? .lightGray
        let textColor = textColorForState?(displayState) ?? .white
        
        let showIndicator: Bool = displayState == .quering
        
        DispatchQueue.main.async {
            self.leftViewMode = showIndicator ? .always : .never
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.borderColor = borderColor.cgColor
                self.backgroundColor = backgroundColor
                self.textColor = textColor
            })
        }
    }
    
    deinit {
        self.removeTarget(self, action: nil, for: .editingChanged)
    }
}

extension ReceiverTextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextHandler?()
        return false
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingHandler?(self)
    }
    
    func textFielDidChanged(_ textField: UITextField) -> Void {
        textDidChanged?(self)
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing?(self) ?? true
    }
        
    override public func deleteBackward() {
        if self.text == nil || self.text?.characters.count == 0 {
            reachEmptyDeleting?(self)
        }
        super.deleteBackward()
    }
}
