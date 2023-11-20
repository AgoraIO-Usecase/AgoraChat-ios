//
//  AgoraEditTextView.swift
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/7/25.
//  Copyright © 2023 easemob. All rights reserved.
//

import UIKit

@objc public final class AgoraEditTextView: UIView {
    
    private var modifyClosure:((String) -> Void)?
    
    private var keyboardHeight = CGFloat(0)
    
    private var placeHolderHeight = CGFloat(20)
    
    private var normalFrame = CGRect.zero
    
    lazy var containerView: UIView = {
        UIView(frame: CGRect(x: 0, y: ScreenHeight-154, width: self.frame.width, height: self.frame.height-154)).backgroundColor(.white).cornerRadius(12, [.topLeft,.topRight], .clear, 0)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .system).frame(.zero).title("Cancel", .normal).font(.systemFont(ofSize: 16, weight: .medium)).tag(11).addTargetFor(self, action: #selector(operationAction(sender:)), for: .touchUpInside)
    }()
    
    lazy var done: UIButton = {
        UIButton(type: .system).frame(.zero).title("Done", .normal).font(.systemFont(ofSize: 16, weight: .medium)).tag(12).addTargetFor(self, action: #selector(operationAction(sender:)), for: .touchUpInside).textColor(UIColor(0x999999), .disabled)
    }()
    
    lazy var title: UILabel = {
        UILabel(frame: .zero).font(.systemFont(ofSize: 18, weight: .medium)).text("Message Edit").textColor(.black)
    }()
    
    lazy var editor: TextEditorView = {
        TextEditorView(frame: .zero)
    }()
    
    @objc public convenience init(title: String,placeHolder: String,changeClosure: @escaping (String) -> Void) {
        self.init(frame: UIScreen.main.bounds)
        self.modifyClosure = changeClosure
        let backgroundLayer = CALayer()
        backgroundLayer.frame = self.bounds
        backgroundLayer.backgroundColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.addSublayer(backgroundLayer)
        self.backgroundColor = .clear
        self.addSubview(self.containerView)
        self.containerView.addSubViews([self.cancel,self.done,self.title,self.editor])
        self.cancel.translatesAutoresizingMaskIntoConstraints = false
        self.cancel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8).isActive = true
        self.cancel.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 4).isActive = true
        self.cancel.widthAnchor.constraint(equalToConstant: 86).isActive = true
        self.cancel.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        self.done.translatesAutoresizingMaskIntoConstraints = false
        self.done.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8).isActive = true
        self.done.rightAnchor.constraint(equalTo: self.containerView.rightAnchor, constant: -4).isActive = true
        self.done.widthAnchor.constraint(equalToConstant: 78).isActive = true
        self.done.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.title.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 11).isActive = true
        self.title.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor).isActive = true
        self.title.widthAnchor.constraint(equalToConstant: 120).isActive = true
        self.title.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        self.title.text = title
        self.editor.placeholder = placeHolder
        self.editor.placeholderFont = .systemFont(ofSize: 14, weight: .regular)
        self.editor.textView.font = .systemFont(ofSize: 14, weight: .medium)
        
        let contentHeight = placeHolder.sizeWithText(font: .systemFont(ofSize: 14, weight: .medium), size: CGSize(width: self.frame.width-16, height: ScreenHeight/2.0)).height+46+CGFloat(BottombarHeight)+20
        if contentHeight > 154 {
            let containerY = ScreenHeight-contentHeight
            self.containerView.frame = CGRect(x: 0, y: containerY, width: self.frame.width, height: contentHeight)
            self.placeHolderHeight = contentHeight
        }
       
        self.editor.translatesAutoresizingMaskIntoConstraints = false
        self.editor.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 8).isActive = true
        self.editor.rightAnchor.constraint(equalTo: self.containerView.rightAnchor, constant: -8).isActive = true
        self.editor.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 46).isActive = true
        self.editor.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -CGFloat(BottombarHeight)).isActive = true
        self.normalFrame = self.containerView.frame
        self.done.isEnabled = false
        self.editor.textDidChanged = { [weak self] in
            self?.done.isEnabled = !$0.isEmpty
        }
        self.editor.heightDidChangedShouldScroll = { [weak self] in
            guard let `self` = self else { return true }
            var changeHeight = ($0+46+CGFloat(BottombarHeight)+20)
            if changeHeight > ScreenHeight/2.0 {
                changeHeight = ScreenHeight/2.0
                self.placeHolderHeight = changeHeight
                self.containerView.frame = CGRect(x: 0, y: ScreenHeight - ($0+46+CGFloat(BottombarHeight)+20) - self.keyboardHeight, width: self.containerView.frame.width, height: changeHeight)
                return true
            } else {
                self.placeHolderHeight = changeHeight
                self.containerView.frame = CGRect(x: 0, y: ScreenHeight - ($0+46+CGFloat(BottombarHeight)+20) - self.keyboardHeight, width: self.containerView.frame.width, height: changeHeight)
                return false
            }
        }
//        self.containerView.translatesAutoresizingMaskIntoConstraints = false
//        self.containerView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        self.containerView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//        self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        self.containerView.heightAnchor.constraint(equalTo:self.editor.heightAnchor, constant: 0).isActive = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AgoraEditTextView {
    
    public func getWindow()-> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
                .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
            // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    @objc public func show() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1) {
            self.getWindow()?.addSubview(self)
        }
    }
    
    @objc public func hidden() {
        self.editor.textView.resignFirstResponder()
        self.editor.endEditing(true)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { finished in
            if finished {
                self.removeFromSuperview()
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let point = touches.first?.location(in: self), !self.containerView.frame.contains(point) {
            self.removeFromSuperview()
        }
    }
    
    @objc private func operationAction(sender: UIButton) {
        if sender.tag == 12 {
            if !self.editor.textView.text.isEmpty,let text = self.editor.textView.text {
                self.modifyClosure?(text)
            }
        }
        self.hidden()
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if !self.editor.textView.isFirstResponder {
            return
        }
        let frame = notification.keyboardEndFrame
        let duration = notification.keyboardAnimationDuration
        keyboardHeight = frame!.height
        UIView.animate(withDuration: duration!) {
            self.containerView.frame = CGRect(x: 0, y: ScreenHeight - 154 - frame!.height, width: self.containerView.frame.width, height: self.containerView.frame.height)
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        let frame = notification.keyboardEndFrame
        let duration = notification.keyboardAnimationDuration
        keyboardHeight = frame!.height
        UIView.animate(withDuration: duration!) {
            self.containerView.frame = CGRect(x: 0, y: ScreenHeight-self.placeHolderHeight, width: ScreenWidth, height: self.placeHolderHeight)
        }
    }
}

extension String {
    func sizeWithText(font: UIFont, size: CGSize) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect.size;
    }
}
