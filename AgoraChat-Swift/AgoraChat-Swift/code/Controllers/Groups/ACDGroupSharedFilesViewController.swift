//
//  ACDGroupSharedFilesViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/26.
//

import UIKit
import Photos
import SnapKit
import QuickLook

class ACDGroupSharedFilesViewController: ACDContainerSearchTableViewController<AgoraChatGroupSharedFile> {

    private let navView = ACDGroupMemberNavView()
    private let noDataPromptView = ACDNoDataPlaceHolderView()
    
    private let group: AgoraChatGroup
    private let dateFormatter = DateFormatter()
    private lazy var imagePicker: UIImagePickerController = {
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        return vc
    }()
    
    
    init(group: AgoraChatGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        AgoraChatClient.shared().groupManager?.add(self, delegateQueue: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Share Files".localized
        self.view.backgroundColor = .white
        
        self.setupSubViews()
        
        self.fetchFiles(refresh: true)
    }
    
    func setupSubViews() {
        self.navView.leftLabel.text = "Group Files".localized
        self.navView.leftButtonHandle = { [unowned self] in
            self.backAction()
        }
        self.navView.rightButtonHandle = { [unowned self] in
            self.moreAction()
        }
        self.navView.rightButton.setImage(UIImage(named: "chat_nav_add"), for: .normal)
        
        self.noDataPromptView.noDataImageView.image = UIImage(named: "no_search_result")
        self.noDataPromptView.prompt.text = ""
        self.noDataPromptView.isHidden = true
        
        self.table.rowHeight = 54
        self.table.register(UINib(nibName: "ACDAvatarNameCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.navView)
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.table)
        self.view.addSubview(self.noDataPromptView)
        
        self.navView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.searchBar.snp.top).offset(-5)
        }
        self.searchBar.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.left.right.equalTo(self.view)
            make.height.equalTo(32)
        }
        self.table.snp.remakeConstraints { make in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
        self.noDataPromptView.snp.makeConstraints { make in
            make.top.equalTo(self.searchBar)
            make.left.width.height.equalTo(self.table)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    deinit {
        AgoraChatClient.shared().groupManager?.removeDelegate(self)
    }
    
    private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func moreAction() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Upload Image".localized, iconImage: UIImage(named: "groupShareImage"), textColor: .black, alignment: .left, completion: { _ in
            self.uploadMediaAction(0)
        }))
        vc.addAction(UIAlertAction(title: "Upload Video".localized, iconImage: UIImage(named: "groupShareVideo"), textColor: .black, alignment: .left, completion: { _ in
            self.uploadMediaAction(1)
        }))
        vc.addAction(UIAlertAction(title: "Upload File".localized, iconImage: UIImage(named: "groupShareFile"), textColor: .black, alignment: .left, completion: { _ in
            self.uploadFileAction()
        }))
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(vc, animated: true)
    }
    
    private func uploadMediaAction(_ tag: Int) {
        self.imagePicker.sourceType = .photoLibrary
        if tag == 0 {
            self.imagePicker.mediaTypes = ["public.image"]
        } else {
            self.imagePicker.mediaTypes = ["public.movie"]
        }
        self.present(self.imagePicker, animated: true)
    }
    
    private func uploadFileAction() {
        let types: [String] = ["public.content", "public.text", "public.source-code", "public.image", "public.jpeg", "public.png", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt"]
        let vc = UIDocumentPickerViewController(documentTypes: types, in: .open)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    override func didStartRefresh() {
        self.fetchFiles(refresh: true)
    }
    
    override func didStartLoadMore() {
        self.fetchFiles(refresh: false)
    }
    
    private func fetchFiles(refresh: Bool) {
        if refresh {
            self.page = 1
        }
        AgoraChatClient.shared().groupManager?.getGroupFileList(withId: self.group.groupId, pageNumber: Int(self.page), pageSize: 20, completion: { files, error in
            self.endRefresh()
            if let error = error {
                self.showHint(error.errorDescription)
            } else if let files = files {
                if refresh {
                    self.dataArray.removeAll()
                    for file in files {
                        self.dataArray.append(file)
                    }
                }
            }
            if files?.count ?? 0 < 20 {
                self.endLoadMore()
                self.loadMoreCompleted()
            } else {
                self.useLoadMore()
            }
            self.updateUI()
        })
    }
    
    private func updateUI() {
        self.searchSource.removeAll()
        self.searchSource.append(contentsOf: self.dataArray)
        self.table.reloadData()
        self.navView.leftSubLabel.text = "(\(self.dataArray.count))"
        self.noDataPromptView.isHidden = self.dataArray.count > 0
    }
    
    private func fileIcon(fileName: String) -> UIImage? {
        let fileTypeString = fileName.components(separatedBy: ".").last
        if let fileTypeString = fileTypeString, ["jpg", "mp4", "docx", "xlsx", "pdf", "zip", "txt"].contains(fileTypeString) {
            return UIImage(named: "file_\(fileTypeString)") ?? UIImage(named: "file_unknow")
        }
        return UIImage(named: "file_unknow")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearchState ? self.searchResults.count : self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDAvatarNameCell {
            if let file = (self.isSearchState ? self.searchResults[indexPath.row] : self.dataArray[indexPath.row]) as? AgoraChatGroupSharedFile {
                cell.avatarView.image = self.fileIcon(fileName: file.fileName)
                if file.fileName.count > 0 {
                    cell.nameLabel.text = file.fileName
                } else {
                    cell.nameLabel.text = file.fileId
                }
                let date = Date(timeIntervalSince1970: Double(file.createdAt) / 1000)
                let createTime = self.dateFormatter.string(from: date)
                cell.detailLabel.text = String(format: "%@ %@ %.2lf MB", file.fileOwner ?? "", createTime, Float(file.fileSize) / 1024 / 1024)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteFileCellAction(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var filePath = "\(NSHomeDirectory())/Library/appdata/download"
        if !FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true)
        }
        if let file = (self.isSearchState ? self.searchResults[indexPath.row] : self.dataArray[indexPath.row]) as? AgoraChatGroupSharedFile {
            guard let fileName = file.fileName.count > 0 ? file.fileName : file.fileId else {
                return
            }
            filePath += "/\(fileName)"
            
            if FileManager.default.fileExists(atPath: filePath) {
                self.openFile(path: filePath)
            } else {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                AgoraChatClient.shared().groupManager?.downloadGroupSharedFile(withId: self.group.groupId, filePath: filePath, sharedFileId: file.fileId, progress: nil, completion: { _, error in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if error != nil {
                        self.showHint("Operation failed".localized)
                    } else {
                        self.openFile(path: filePath)
                    }
                })
            }
        }
    }
    
    private func openFile(path: String) {
        let url = URL(fileURLWithPath: path)
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        vc.excludedActivityTypes = [.message, .mail, .saveToCameraRoll, .airDrop]
        self.present(vc, animated: true)
    }
    
    private func deleteFileCellAction(indexPath: IndexPath) {
        let file = self.dataArray[indexPath.row]
        let vc = UIAlertController(title: "Are you sure to delete?".localized, message: file.fileName, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        vc.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: { _ in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            AgoraChatClient.shared().groupManager?.removeGroupSharedFile(withId: self.group.groupId, sharedFileId: file.fileId, completion: { _, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if error != nil {
                    self.showHint("Operation failed".localized)
                } else {
                    for i in 0..<self.dataArray.count where self.dataArray[i].fileId == file.fileId {
                        self.dataArray.remove(at: i)
                        self.updateUI()
                        break
                    }
                }
            })
        }))
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension ACDGroupSharedFilesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[.mediaType] as? String
        if mediaType == "public.movie" {
            if let url = info[.mediaURL] as? URL, let mp4Url = self.videoConvert2Mp4(url: url) {
                try? FileManager.default.removeItem(at: url)
                self.uploadAction(filePath: mp4Url.path)
            }
        } else if mediaType == "public.image" {
            if let url = info[.referenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
                result.enumerateObjects { asset, _, stop in
                    PHImageManager.default().requestImageData(for: asset, options: nil) { data, uti, orientation, dict in
                        if let data = data {
                            let url = dict?["PHImageFileURLKey"] as? URL
                            let fileName = (url?.absoluteString as? NSString)?.lastPathComponent
                            self.uploadFile(data: data, fileName: fileName)
                        }
                    }
                }
            } else {
                if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 1) {
                    self.uploadFile(data: data, fileName: nil)
                }
            }
        }
        
        picker.dismiss(animated: true)
    }
    
    private func uploadFile(data: Data, fileName: String?) {
        var filePath = "\(NSHomeDirectory())/Library/appdata/files"
        if !FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true)
        }
        
        if let fileName = fileName, fileName.count > 0 {
            filePath += "/\(Date().timeIntervalSince1970)\(fileName)"
        } else {
            filePath += "/\(Date().timeIntervalSince1970)\(arc4random() % 100000).jpg"
        }
        _ = (data as NSData).write(toFile: filePath, atomically: true)
        self.uploadAction(filePath: filePath)
    }
    
    private func videoConvert2Mp4(url: URL) -> URL? {
        guard let path = self.getAudioOrVideoPath() else {
            return nil
        }
        let asset = AVURLAsset(url: url)
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        if compatiblePresets.contains(AVAssetExportPresetHighestQuality) {
            guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
                return nil
            }
            let mp4Path = "\(path)/\(Date().timeIntervalSince1970)\(arc4random() % 100000).mp4"
            let mp4Url = URL(fileURLWithPath: mp4Path)
            session.outputURL = mp4Url
            session.shouldOptimizeForNetworkUse = true
            session.outputFileType = .mp4
            let wait = DispatchSemaphore(value: 0)
            session.exportAsynchronously {
                wait.signal()
            }
            wait.wait()
            return mp4Url
        }
        return nil
    }
    
    private func getAudioOrVideoPath() -> String? {
        guard var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return nil
        }
        path += "/groupShareRecord"
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
        return path
    }
    
    private func uploadAction(filePath: String) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().groupManager?.uploadGroupSharedFile(withId: self.group.groupId, filePath: filePath, progress: nil, completion: { file, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                self.showHint("Operation failed".localized)
            } else if let file = file {
                self.dataArray.insert(file, at: 0)
                self.updateUI()
            }
        })
    }
}

extension ACDGroupSharedFilesViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first, url.startAccessingSecurityScopedResource() {
            self.selectedDocumentAt(url: url, name: nil)
            url.stopAccessingSecurityScopedResource()
        } else {
            self.showHint("Operation failed".localized)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if url.startAccessingSecurityScopedResource() {
            self.selectedDocumentAt(url: url, name: nil)
            url.stopAccessingSecurityScopedResource()
        } else {
            self.showHint("Operation failed".localized)
        }
    }

    private func selectedDocumentAt(url: URL, name: String?) {
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        fileCoordinator.coordinate(readingItemAt: url, options: [], error: nil) { newUrl in
            let fileName = newUrl.lastPathComponent
            if let fileData = try? Data(contentsOf: newUrl) {
                self.uploadFile(data: fileData, fileName: fileName)
            } else {
                self.showHint("Operation failed".localized)
            }
        }
    }
}

extension ACDGroupSharedFilesViewController: AgoraChatGroupManagerDelegate {
    func groupFileListDidUpdate(_ aGroup: AgoraChatGroup, addedSharedFile aSharedFile: AgoraChatGroupSharedFile) {
        if aGroup.groupId == self.group.groupId {
            self.reloadDataArrayAndView()
        }
    }
    
    func groupFileListDidUpdate(_ aGroup: AgoraChatGroup, removedSharedFile aFileId: String) {
        if aGroup.groupId == self.group.groupId {
            self.reloadDataArrayAndView()
        }
    }
    
    private func reloadDataArrayAndView() {
        self.dataArray.removeAll()
        for i in self.group.sharedFileList {
            self.dataArray.append(i)
        }
        self.updateUI()
    }
}
