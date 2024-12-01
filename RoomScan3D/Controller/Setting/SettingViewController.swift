//
//  SettingViewController.swift
//  RoomScan3D
//
//  Created by Vuong Doan on 16/10/24.
//

import Foundation
import UIKit
import SafariServices
import MessageUI
import StoreKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        let backButton = UIBarButtonItem(title: "Back", image: nil, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItems = [backButton]
    }
    
    @objc func backAction() {
        self.dismissDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTable()
        
    }

    func setupTable() {
        tableView.register(UINib(nibName: "SettingCells", bundle: nil), forCellReuseIdentifier: "SettingCells")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    func goToViewClickCell(dataSetting: SettingModels) {
        let typeSettingCell = dataSetting.type
        
        switch typeSettingCell {
        case .PassCode:
            goToPassCodeScreen()
        case .SendFeedBack:
            goToEmailUS()
        case .ShareWithFriend:
            shareImageWithSocial()
        case .LikeUs:
            rateApp()
        case .PrivacyPolicy:
            goToPolicy()
        case .TermOfUse:
            goToTermOfUse()
        }
    }
    
    func goToPolicy() {
        if let url = URL(string: Configs.urlPolicy) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func goToTermOfUse() {
        if let url = URL(string: Configs.urlTermOfUse) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func goToPassCodeScreen() {
       
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()

        } else if let url = URL(string: Configs.urlAppStore) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func goToEmailUS() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(Configs.emailContact)"])
            mail.setSubject("Scan 3D Room")
            mail.setMessageBody("<p>Feedback here</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func shareImageWithSocial() {
        // image to share
        guard let url = URL(string: Configs.urlAppStore) else { return }
        let itemShare: [Any] = [url]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: itemShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = []
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            print("Nothing")
        case .pad:
            activityViewController.popoverPresentationController?.sourceView = contentView
            
        @unknown default:
            print("Nothing")
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Configs.dataSetting.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Configs.dataSetting[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCells", for: indexPath) as! SettingCells
        cell.selectionStyle = .none
        let dataSettingSession = Configs.dataSetting[indexPath.section]
        let idx = indexPath.row
        
        cell.setupUI(dataSetting: dataSettingSession[idx])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idx = indexPath.row
        let dataSettingSession = Configs.dataSetting[indexPath.section]
        goToViewClickCell(dataSetting: dataSettingSession[idx])
    }
    
}
