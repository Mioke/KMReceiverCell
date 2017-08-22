//
//  ReceiverCell.swift
//  FileMail
//
//  Created by jiangkelan on 18/05/2017.
//  Copyright © 2017 xlvip. All rights reserved.
//

import UIKit

private let screenWidth = UIScreen.main.bounds.size.width
private let gapWidth: CGFloat = 10
private let maxWidth = (screenWidth - 28)
private let minWidth: CGFloat = 64


public class ReceiverCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK: - IB outlets
    @IBOutlet weak var sendToLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var beginEditingButton: UIButton!
    @IBOutlet weak var pillar: NSLayoutConstraint!
    @IBOutlet weak var receiversInfoLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    // MARK: - Public properties
    public var isInputing: Bool = false {
        didSet {
//            guard oldValue != isInputing else { return }
            
            beginEditingButton.isHidden = isInputing
            addButton.isHidden = !isInputing && self.receivers.count > 0
            receiversInfoLabel.isHidden = isInputing || self.receivers.count == 0
            placeholderLabel.isHidden = isInputing || self.receivers.count > 0
            
            pillar.constant = isInputing ? CGFloat(lineCounts * 48) : 48
            
            DispatchQueue.main.async {
                self.shouldReloadCellBlock?()
                
                let alpha: CGFloat = self.isInputing ? 1.0 : 0.0
                UIView.animate(withDuration: 0.1, animations: { 
                    for inp in self.inputers {
                        inp.alpha = alpha
                    }
                })
                if self.isInputing == false {
                    self.setAllTextField(to: .normal)
                }
            }
        }
    }
    
    public var lineCounts = 1 {
        didSet {
            pillar.constant = isInputing ? CGFloat(lineCounts * 48) : 48
            DispatchQueue.main.async {
                self.shouldReloadCellBlock?()
            }
        }
    }
    public var xseeker: CGFloat = 0
    public var receivers: [ReceiverCellModel] = [] {
        didSet {
            let generalText = "  等\(receivers.count)人"
            let generalWidth = textWidth(of: generalText)
            let restWidth = screenWidth - sendToLabel.frame.origin.x - sendToLabel.frame.size.width - 14 - generalWidth
            
            var info = ""
            var index = 0
            
            for receiver in receivers {
                var new = info
                if index > 0 {
                    new = new + " 、"
                }
                new = new + receiver.fullName
                let width = textWidth(of: new)
                
                if width > restWidth {
                    if index == 0 {
                        let start = receiver.fullName.characters.index(
                            receiver.fullName.characters.startIndex,
                            offsetBy: 0
                        )
                        let end = receiver.fullName.characters.index(
                            receiver.fullName.characters.startIndex,
                            offsetBy: (receiver.fullName.characters.count / 2)
                        )
                        info = receiver.fullName[start ..< end] + "..." + generalText
                    } else {
                        info = info + generalText
                    }
                    break
                } else {
                    info = new
                }
                index += 1
            }
            receiversInfoLabel.text = info
        }
    }
    public var inputers: [ReceiverTextField] = []
    
    // MARK: - Private properties
    private var maxTextFieldWidth: CGFloat!
    private var isAdding: Bool = false
    
    // MARK: - Callbacks & delegates
    public var shouldReloadCellBlock: (() -> Void)?
    public var shouldReplaceNameHandler: ((String) -> ReceiverCellModel?)?
    public var errorhandler: ((NSError) -> Void)?
    public var typeAddHandler: ((ReceiverCellModel) -> Void)?
    public var replaceAddHandler: ((ReceiverCellModel) -> Void)?
    public var deleteHandler: ((ReceiverCellModel) -> Void)?
    public var clickAddButton: (() -> Void)?
    public var doubleClickHandler: ((Int, ReceiverCellModel) -> Void)?
    
    // MARK: - Public functions:
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isInputing = false
    }
    public func add(models: [ReceiverCellModel]) -> Void {
        for model in models {
            addNewInputer(with: model)
        }
        self.receivers.append(contentsOf: models)
    }
    
    public func delete(models: [ReceiverCellModel]) -> Void {
        
        var willDeleted: [ReceiverTextField] = []
        var deletingModels: [ReceiverCellModel] = []
        
        for index in 0..<self.receivers.count {
            let local = self.receivers[index]
            
            let contains = models.contains(where: { (model) -> Bool in
                return model == local
            })
            if contains {
                willDeleted.append(self.inputers[index])
                deletingModels.append(self.receivers[index])
            }
        }
        
        for textfield in willDeleted {
            self.removeReceiverTextField(textfield)
        }
        
        self.receivers = self.receivers.filter { !deletingModels.contains($0) }
        self.layoutTextFieldsIfNeeded() 
    }
    
    public func replace(model: ReceiverCellModel, at index: Int) -> Void {
        guard self.inputers.count >= index + 1 else { return }
        
        let inputer = inputers[index]
        inputer.text = model.fullName
        
        let maxWidth = index == 0 ?
            (addButton.frame.origin.x - sendToLabel.frame.origin.x - sendToLabel.frame.size.width - gapWidth * 2) :
            (addButton.frame.origin.x - 14 - gapWidth)
        
        let real = realWidth(for: inputer, with: inputer.font ?? UIFont.systemFont(ofSize: 14))
        inputer.frame.size.width = min(real, maxWidth)
        layoutTextFieldsIfNeeded()
    
        receivers[index] = model
    }
    
    public func beginEditing() -> Void {
        self.beginEditing(1)
    }
    
    public func setAllTextField(to state: ReceiverTextFieldState) -> Void {
        for inp in self.inputers where !inp.isEditing{
            inp.displayState = state
        }
    }
    
    // MARK: - Private functions:
    @IBAction fileprivate func clickAddButton(_ sender: Any) {
        clickAddButton?()
    }

    @IBAction fileprivate func beginEditing(_ sender: Any) {
        addNewInputer()
        isInputing = true
    }
    
    private func realWidth(for inputer: ReceiverTextField, with font: UIFont) -> CGFloat {
        let text = inputer.text ?? ""
        let attributeText = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let rect = attributeText.boundingRect(with: CGSize(width: 999, height: 999),
                                              options: .usesFontLeading,
                                              context: nil)
        let realWidth = rect.size.width + inputer.textEdgeInsets.left + inputer.textEdgeInsets.right
        return realWidth
    }
    
    private func textWidth(of text: String, with font: UIFont = UIFont.systemFont(ofSize: 14)) -> CGFloat {
        let attributeText = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let rect = attributeText.boundingRect(with: CGSize(width: 999, height: 999),
                                              options: .usesFontLeading,
                                              context: nil)
        return rect.size.width
    }
    
    @discardableResult
    private func addNewInputer(with model: ReceiverCellModel? = nil) -> ReceiverTextField {
        if self.maxTextFieldWidth == nil {
            self.maxTextFieldWidth = self.addButton.frame.origin.x - 14 - gapWidth
        }
        if xseeker == 0 {
            xseeker = self.sendToLabel.frame.origin.x + self.sendToLabel.frame.size.width + gapWidth
        }
        
        let restWidth = self.addButton.frame.origin.x - self.xseeker - gapWidth
        let font = UIFont.systemFont(ofSize: 14)
        
        let inputer = ReceiverTextField(frame: CGRect(x: 0, y: 0, width: 0, height: 28))
        inputer.text = model?.fullName
        var originWidth = model == nil ? restWidth : realWidth(for: inputer, with: font)
        
        if model == nil {
            if originWidth < minWidth {
                originWidth = maxTextFieldWidth
                xseeker = 14
                lineCounts += 1
            } else if originWidth > maxTextFieldWidth {
                originWidth = maxTextFieldWidth
            }
        } else {
            if restWidth < originWidth {
                xseeker = 14
                lineCounts += 1
            } else if originWidth > maxTextFieldWidth {
                originWidth = maxTextFieldWidth
            }
        }
        
        inputer.frame = CGRect(x: xseeker, y: (CGFloat(lineCounts - 1)) * 48 + 10, width: originWidth, height: 28)
        inputer.originalWidth = originWidth
        
        self.defaultInitial(for: inputer)
        
        inputer.endEditingHandler = { [weak self] (textfield) in
            guard let ss = self else { return }
            
            defer {
                if !ss.isAdding, (ss.inputers.filter { $0.isEditing }).count == 0 {
                    ss.isInputing = false
                }
            }
            
            guard var text = inputer.text, text.characters.count > 0 else {
                self?.removeReceiverTextField(textfield)
                return
            }
            
            var user: ReceiverCellModel?
            if let replaced = ss.shouldReplaceNameHandler?(text) {
                textfield.text = replaced.fullName
                text = replaced.fullName
                user = replaced
            }
            
            let realWidth = ss.realWidth(for: textfield, with: font)
            
            if realWidth > textfield.frame.size.width {
                
            } else {
                textfield.frame.size.width = realWidth
            }
            self?.xseeker = inputer.frame.origin.x + realWidth + gapWidth
            
            textfield.displayState = .normal
            
            // Add model
            let model = user ?? ReceiverCellModel(withID: nil, name: text)
            if (ss.receivers.filter { $0 == model }).count == 0 {
                if user == nil {
                    ss.typeAddHandler?(model)
                } else {
                    ss.replaceAddHandler?(model)
                }
                ss.receivers.append(model)
            } else {
                ss.errorhandler?(
                    NSError(domain: "",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "已存在相同联系人"])
                )
                ss.removeReceiverTextField(textfield)
            }
        }
        
        inputer.textDidChanged = { [weak self] textField in
            guard
                let ss = self,
                let _ = textField.text,
                textField.originalWidth < ss.maxTextFieldWidth,
                let first = ss.inputers.first,
                first != textField
            else { return }
            
            let realWidth = ss.realWidth(for: inputer, with: font)
            var shouldReload = true
            
            if realWidth > textField.originalWidth, textField.frame.size.width < ss.maxTextFieldWidth {
                textField.frame.size.width = ss.maxTextFieldWidth
            } else if realWidth < textField.originalWidth, textField.frame.size.width > textField.originalWidth {
                textField.frame.size.width = textField.originalWidth
            } else { shouldReload = false }
            
            if shouldReload {
                self?.layoutTextFieldsIfNeeded()
            }
        }
        
        inputer.font = font
        self.contentView.insertSubview(inputer, belowSubview: self.beginEditingButton)
        self.inputers.append(inputer)
        
        // 1. begin editing
        if model == nil {
            inputer.becomeFirstResponder()
            inputer.displayState = .editing
        } else {
            inputer.displayState = .normal
            xseeker = inputer.frame.origin.x + inputer.frame.size.width + gapWidth
        }
        // 2. set here for preventing begin editing after creation
        inputer.shouldBeginEditing = { [weak self] textfield in
            
            guard let ss = self else { return false }
            
            if textfield.displayState == .selected {
                var index = 0
                
                for inp in ss.inputers {
                    if inp.displayState == .selected { break }
                    index += 1
                }
                ss.doubleClickHandler?(index, ss.receivers[index])
            } else {
                ss.setTextFieldSelected(textfield)
            }
            return false
        }
        return inputer
    }
    
    fileprivate func defaultInitial(for textfield: ReceiverTextField) -> Void {
        textfield.alpha = self.isInputing ? 1 : 0
        
        textfield.backgroundColorForState = textFieldBackgroundColor
        textfield.textColorForState = textFieldTextColor
        
        textfield.reachEmptyDeleting = { [weak self] textfield in
            guard let ss = self, ss.inputers.count > 1 else { return }
            
            var selected: ReceiverTextField?
            var index = 0
            for inp in ss.inputers {
                if inp.displayState == .selected {
                    selected = inp
                    break
                }
                index += 1
            }
        
            index = selected == nil ? ss.inputers.count - 2 : index
            let deleting = selected ?? ss.inputers[index]
            
            if deleting.displayState == .selected {
                ss.removeReceiverTextField(deleting)
                
                if selected == nil {
                    textfield.frame.size.width = deleting.frame.size.width
                }
                ss.layoutTextFieldsIfNeeded()
                
                if textfield.frame.origin.x < 15 {
                    if ss.inputers.count > 1 {
                        let last = ss.inputers[ss.inputers.count - 2]
                        let rest = ss.addButton.frame.origin.x - last.frame.origin.x - last.frame.size.width - gapWidth * 2
                        
                        if rest > minWidth {
                            ss.updateTextFieldWidth(textfield, width: rest)
                            ss.layoutTextFieldsIfNeeded()
                        } else {
                            ss.updateTextFieldWidth(textfield, width: ss.maxTextFieldWidth)
                        }
                    } else {
                        let rest = ss.addButton.frame.origin.x - ss.sendToLabel.frame.origin.x - ss.sendToLabel.frame.size.width - gapWidth * 2
                        ss.updateTextFieldWidth(textfield, width: rest)
                        ss.layoutTextFieldsIfNeeded()
                    }
                } else {
                    ss.updateTextFieldWidth(textfield, width: ss.addButton.frame.origin.x - textfield.frame.origin.x - gapWidth)
                }
                
                let model = ss.receivers.remove(at: index)
                ss.deleteHandler?(model)
            } else {
                ss.setTextFieldSelected(deleting)
            }
        }
        
        textfield.nextHandler = { [weak self] in
            guard let text = textfield.text, text.characters.count > 0 else {
                return
            }
            self?.isAdding = true; defer { self?.isAdding = false }
            textfield.resignFirstResponder()
            self?.addNewInputer()
        }
    }
    
    fileprivate func layoutTextFieldsIfNeeded() -> Void {
        xseeker = self.sendToLabel.frame.origin.x + self.sendToLabel.frame.size.width + gapWidth
        var row = 0
        
        for textfield in inputers {
            let width = self.addButton.frame.origin.x - self.xseeker - gapWidth
            
//            if textfield.isEditing {
//                let resize = width > minWidth ? width : self.maxTextFieldWidth!
//                self.updateTextFieldWidth(textfield, width: resize)
//            }
            if width < textfield.frame.size.width {
                xseeker = 14
                row += 1
            }
            textfield.frame.origin = CGPoint(x: xseeker, y: (CGFloat(row)) * 48 + 10)
            xseeker += textfield.frame.size.width + gapWidth
        }
        if row + 1 != lineCounts {
            lineCounts = row + 1
        }
    }
    
    private func updateTextFieldWidth(_ textfield: ReceiverTextField, width: CGFloat) -> Void {
        textfield.frame.size.width = width
        textfield.originalWidth = textfield.frame.size.width
    }
    
    fileprivate var textFieldBackgroundColor: (ReceiverTextFieldState) -> UIColor? = {
        return { state in
            switch state {
            case .editing:
                return .clear
            case .selected:
                return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            default:
                return #colorLiteral(red: 0.6344515839, green: 0.8982374289, blue: 1, alpha: 1)
            }
        }
    }()
    
    fileprivate var textFieldTextColor: (ReceiverTextFieldState) -> UIColor? = {
        return { _ in
            return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
    }()
    
    fileprivate func setTextFieldSelected(_ textfield: ReceiverTextField) -> Void {
        for inp in self.inputers {
            if !inp.isEditing {
                inp.displayState = .normal
            }
            
            if inp.isEditing, (inp.text?.characters.count ?? 0) > 0 {
                self.isAdding = true; defer { self.isAdding = false }
                inp.resignFirstResponder()
                self.addNewInputer()
            }
        }
        textfield.displayState = .selected
    }
    
    fileprivate func removeReceiverTextField(_ textField: ReceiverTextField) -> Void {
        textField.removeFromSuperview()
        self.inputers = self.inputers.filter { $0 != textField }
        
        if textField.frame.origin.x == 14 {
            lineCounts -= 1
            if let last = self.inputers.last {
                xseeker = last.frame.origin.x + last.frame.size.width + gapWidth
            }
        } else {
            xseeker = textField.frame.origin.x
        }
    }
}
