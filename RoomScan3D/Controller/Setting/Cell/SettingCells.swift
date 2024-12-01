//
//  SettingCells.swift
//  RoomScan3D
//
//  Created by Vuong Doan on 16/10/24.
//


import Foundation
import UIKit

class SettingCells: UITableViewCell {
    
    @IBOutlet weak var settingImage: UIImageView!
    @IBOutlet weak var settingName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 12
    }
    
    func setupUI(dataSetting: SettingModels) {
        settingName.text = "\(dataSetting.name)"
        settingImage.image = dataSetting.image
    }
}
