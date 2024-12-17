//
//  ViewCellController.swift
//  RoomScan3D
//
//  Created by Doan Tran Hieu My on 10/10/24.
//

import Foundation
import UIKit
import SceneKit

protocol ViewCellControllerProtocol {
    func clickFavoriteButton(index: Int)
}

class ViewCellController: UITableViewCell {
    @IBOutlet weak var modelPreviewView: SCNView!
    @IBOutlet weak var modelName: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var containnerDesView: UIView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var delegate: ViewCellControllerProtocol?
    
    var itemDataCapture: ModelDataCapture?
    var index: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containnerDesView.layer.cornerRadius = 20
        modelPreviewView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 20)
        containnerDesView.layer.shadowColor = UIColor.gray.cgColor
        containnerDesView.layer.shadowOpacity = 1
        containnerDesView.layer.shadowOffset = CGSize.zero
    }
    
    func setupCell(itemDataCapture: ModelDataCapture, index: Int) {
        self.itemDataCapture = itemDataCapture
        self.index = index
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let creationDate = formatter.string(from: itemDataCapture.creationDate)
        let model = try! SCNScene(url: URL(string: itemDataCapture.filePath)!)
        model.background.contents = UIColor.gray
        modelPreviewView.allowsCameraControl = true
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        
        lightNode.light?.type = .directional
        lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
        lightNode.light?.color = UIColor.yellow
        model.rootNode.addChildNode(lightNode)
        modelPreviewView.scene = model
        self.modelName.text = (itemDataCapture.filePath as NSString).lastPathComponent
        self.createDateLabel.text = creationDate
        print("itemDataCapture.isFavorite \(itemDataCapture.isFavorite)")
        self.favouriteButton.isSelected = itemDataCapture.isFavorite
    }
    
    @IBAction func favouriteButtonAction(_ sender: Any) {
        self.favouriteButton.isSelected = !(itemDataCapture?.isFavorite ?? false)
        if let index = index {
            self.delegate?.clickFavoriteButton(index: index)
        }
        
    }
    
}
