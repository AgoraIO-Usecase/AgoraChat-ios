//
//  ChatPhoto.swift
//  AgoraChat-Swift
//
//  Created by 朱继超 on 2024/7/8.
//

import UIKit

@objcMembers final public class PreviewImage: NSObject {
    public var image: UIImage?
    public var urlString: String?
    public var placeholderImage : UIImage?
    public var originalView: UIImageView?
    
    public init(image: UIImage, originalView: UIImageView? = nil) {
        super.init()
        self.image = image
        self.originalView = originalView
    }
    
    public init(urlString: String, placeholderImage: UIImage? = nil, originalView: UIImageView? = nil) {
        super.init()
        self.urlString = urlString
        self.placeholderImage = placeholderImage
        self.originalView = originalView
    }
}

@objc public protocol ImageBrowserProtocol {
    
    func numberOfPhotos(with browser: ImagePreviewController) -> Int
    
    func photo(of index: Int, with browser: ImagePreviewController) -> PreviewImage

    @objc optional func didDisplayPhoto(at index: Int, with browser: ImagePreviewController) -> Void
    
    @objc optional func didLongPressPhoto(at index: Int, with browser: ImagePreviewController) -> Void
    
}
