//
//  ACDTextViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import UIKit

class ACDTextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    private let text: String
    private let placeholder: String
    private let isEditable: Bool
    
    var doneCompletion: ((_ text: String) -> Bool)?
    
    init(text: String, placeholder: String, isEditable: Bool) {
        self.text = text
        self.placeholder = placeholder
        self.isEditable = isEditable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelBtn = UIButton(type: .custom)
        cancelBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelBtn.setTitleColor(Color_154DFE, for: .normal)
        cancelBtn.setTitle(LocalizedString.Cancel, for: .normal)
        cancelBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        
        if self.isEditable {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .plain, target: self, action: #selector(doneAction))
        }
        self.textView.text = self.text
        self.textView.becomeFirstResponder()
    }
    
    @objc private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneAction() {
        self.view.endEditing(true)
        if self.doneCompletion?(self.textView.text) ?? true {
            self.goBack()
        }
    }
}

extension ACDTextViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
