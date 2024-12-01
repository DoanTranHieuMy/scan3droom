//
//  ViewCellController.swift
//  RoomScan3D
//
//  Created by Doan Tran Hieu My on 10/10/24.
//

import Foundation
import UIKit
import SceneKit

class ViewCellController: UITableViewCell {
    @IBOutlet weak var modelPreviewView: SCNView!
    @IBOutlet weak var modelName: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(path: String, modelName: String, createDate: String) {
        let model = try! SCNScene(url: URL(string: path)!)
        model.background.contents = UIColor.gray
        modelPreviewView.allowsCameraControl = true
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        
        lightNode.light?.type = .directional
        lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
        lightNode.light?.color = UIColor.yellow
        model.rootNode.addChildNode(lightNode)
        modelPreviewView.scene = model
        self.modelName.text = modelName
        self.createDateLabel.text = createDate
    }
}
