//
//  Configs.swift
//  RoomScan3D
//
//  Created by Vuong Doan on 16/10/24.
//

import Foundation
import UIKit

class Configs {
    static var emailContact = "khuyentth95@gmail.com"
    static let adMobAdId: String = "ca-app-pub-5643829825649081/3574532200"
    static let urlAppID: String = "https://apps.apple.com/app/id6450154548"
    static let urlTermsOfUse: String = "https://d3q5sq5jmatyie.cloudfront.net/ringtone/terms-of-use.html"
    static let urlPrivacy: String = "https://d3q5sq5jmatyie.cloudfront.net/ringtone/privacy-policy.html"
    static let serverURL: String = "https://d3q5sq5jmatyie.cloudfront.net/ringtone/audio.json"
    static let urlAppStore: String = "https://apps.apple.com/app/id6511249437"
    static let urlPolicy: String = "https://ringtone-music-polycy.blogspot.com/2024/07/privacy-policy-this-page-informs-you-of.html"
    static let urlTermOfUse: String = "https://ringtone-music-polycy.blogspot.com/2024/07/ringtone-music-terms-of-use.html"
    static let dataSetting: [[SettingModels]] =
     [
        [
            SettingModels(name: "Send Feedback", image: UIImage(named: "iconSendMail")!, type: .SendFeedBack),
            SettingModels(name: "Share with friends", image: UIImage(named: "iconSettingShare")!, type: .ShareWithFriend),
            SettingModels(name: "Like Us, Rate Us", image: UIImage(named: "iconLikeUs")!, type: .LikeUs)
        ],
        [
            SettingModels(name: "Privacy Policy", image: UIImage(named: "iconPrivacy")!, type: .PrivacyPolicy),
            SettingModels(name: "Terms Of Use", image: UIImage(named: "iconPrivacy")!, type: .TermOfUse)
        ]
     ]
}


struct SettingModels {
    let name: String
    let image: UIImage
    let type: TypeSetting
}


enum TypeSetting {
    case PassCode
    case SendFeedBack
    case ShareWithFriend
    case LikeUs
    case PrivacyPolicy
    case TermOfUse
}
