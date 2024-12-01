//
//  Show2DViewController.swift
//  RoomScan3D
//
//  Created by Doan Tran Hieu My on 11/10/24.
//

import Foundation
import UIKit
import RoomPlan
import SpriteKit

class Show2DViewController: UIViewController {
    
    @IBOutlet weak var skView: SKView!
    var floorShow2D: FloorShow2D?
    
    var capturedRoom: CapturedStructure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cgSize = CGSize(width: skView.bounds.size.width, height: skView.bounds.size.height)
        skView.presentScene(FloorShow2D(capturedRoom: capturedRoom!, frame: cgSize))
        let backButton = UIBarButtonItem(title: "Back", image: nil, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItems = [backButton]
    }
    
    @objc func backAction() {
        self.dismiss(animated: true)
    }
}

