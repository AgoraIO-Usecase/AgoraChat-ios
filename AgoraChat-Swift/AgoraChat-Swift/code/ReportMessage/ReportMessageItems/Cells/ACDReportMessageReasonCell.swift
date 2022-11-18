//
//  ACDReportMessageReasonCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/24.
//

import UIKit

class ACDReportMessageReasonCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet private weak var numLabel: UILabel!
}

extension ACDReportMessageReasonCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + text.count <= 500
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.numLabel.text = "\(self.textView.text.count)/500"
    }
}
