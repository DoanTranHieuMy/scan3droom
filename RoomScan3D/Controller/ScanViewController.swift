//
//  ScanViewController.swift
//  RoomScan3D
//
//  Created by Doan Tran Hieu My on 30/9/24.
//

import Foundation
import UIKit
import RoomPlan
import ARKit

func delay(_ second: Double, clousure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + second) {
        clousure()
    }
}
class ScanViewController: UIViewController {

    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var structureBuider = StructureBuilder(options: .beautifyObjects)
    var roomBuilder = RoomBuilder(options: .beautifyObjects)
    var capturedRoomArray: [CapturedRoom] = []
    
    var doneButton = UIBarButtonItem()
    let fm = FileManager.default
    
    private var roomCaptureView: RoomCaptureView!
    private var finalResults: CapturedRoom?
    private var roomCaptureSessionConfiguration: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRoomCapture()
        
        doneButton = UIBarButtonItem(title: "Done", image: nil, target: self, action: #selector(doneScan))
        navigationItem.rightBarButtonItems = [doneButton]
        
        activityIndicator?.stopAnimating()
    }
    
    
    
    @objc func doneScan() {
        self.stopSession()
        doneButton.isHidden = true
        self.exportButton?.isEnabled = false
    }
    
    
    
    func userDefaultData() {
        let dataCapture = StoreCapture.shared.dataCapture
        do {
            let encoder = JSONEncoder()
            let dataSave = try encoder.encode(dataCapture)
            UserDefaults.standard.setValue(dataSave, forKey: "saveData")
        } catch {
            
        }
    }
    
    func createURLForSaveData(uuid: String) -> URL {
        let path = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let pathFolder = path.appendingPathComponent("capture")
        if !fm.fileExists(atPath: pathFolder.path) {
            try! fm.createDirectory(atPath: pathFolder.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        return pathFolder
    }
    
    private func handleData(pathFoder: URL, completion: @escaping (CapturedStructure) -> Void) {
        Task {
            let structBuilder = StructureBuilder(options: [.beautifyObjects])
            if let captureStructure = try? await structBuilder.capturedStructure(from: capturedRoomArray) {
                try? captureStructure.export(to: pathFoder)
                completion(captureStructure)
            }
        }
    }
    
    
    private func setActiveNavBar() {
        UIView.animate(withDuration: 1.0, animations: {
            self.doneButton.tintColor = .white
            self.exportButton?.alpha = 0.0
        }, completion: { complete in
            self.exportButton?.isHidden = true
        })
    }
    
    private func setCompleteNavBar() {
        self.exportButton?.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.doneButton.tintColor = .systemBlue
            self.exportButton?.alpha = 1.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.startSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delay(1) {
            self.startSession()
        }
    }
    
    
    override func viewWillDisappear(_ flag: Bool) {
        super.viewWillDisappear(flag)
        stopSession()
        setActiveNavBar()
    }
    
    
    private func stopSession() {
        roomCaptureView?.captureSession.stop()
        setCompleteNavBar()
    }
    
    
    private func startSession() {
        roomCaptureView.captureSession.run(configuration: roomCaptureSessionConfiguration)
        setActiveNavBar()
    }
    
    func setupRoomCapture() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        roomCaptureView.captureSession.arSession.delegate = self
        
        view.insertSubview(roomCaptureView, at: 0)

    }
    
    @IBAction func buttonCancelButton(_ sender: Any) {
        stopSession()
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func buttonExportAction(_ sender: Any) {
        if !capturedRoomArray.isEmpty {
            self.activityIndicator?.startAnimating()
            let uuidString = UUID().uuidString
            let path = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
            var pathFolder = path.appendingPathComponent("capture")
            if !fm.fileExists(atPath: pathFolder.path) {
                try! fm.createDirectory(atPath: pathFolder.path, withIntermediateDirectories: true, attributes: nil)
            }
            let fileName = "A\(uuidString).usdz"
            pathFolder.appendPathComponent(fileName)
            handleData(pathFoder: pathFolder) { captureStruct in
                print(captureStruct)
                self.exportButton?.isEnabled = false
                self.activityIndicator?.stopAnimating()
                let createDate = try! self.fm.attributesOfItem(atPath: pathFolder.path)[.creationDate]  as! Date
                let modelDataCapture = ModelDataCapture(url: pathFolder.absoluteURL, data: captureStruct, filePath: pathFolder.absoluteString, creationDate: createDate, nameUSDZ: fileName)
                
                StoreCapture.shared.addCaptureData(data: modelDataCapture)
                self.userDefaultData()
                self.showPopupSuccess()
            }
        }
    }
    
    
    func showPopupSuccess() {
        let alert = UIAlertController(title: "Successfully", message: "Export Successfully", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Back to Home", style: UIAlertAction.Style.default, handler: { action in
            switch action.style {
            case .default:
                self.tabBarController?.selectedIndex = 0
                
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ScanViewController: RoomCaptureViewDelegate {
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
        return true
    }
    
    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
        finalResults = processedResult
        self.exportButton?.isEnabled = true
        self.activityIndicator?.stopAnimating()
    }
}

extension ScanViewController: ARSessionDelegate {
    
}

extension ScanViewController: RoomCaptureSessionDelegate {
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        //
    }
    
    func captureSession(_ session: RoomCaptureSession, didAdd room: CapturedRoom) {
        //
    }
    
    func captureSession(_ session: RoomCaptureSession, didChange room: CapturedRoom) {
        //
    }
    
    func captureSession(_ session: RoomCaptureSession, didRemove room: CapturedRoom) {
        //
    }
    
    func captureSession(_ session: RoomCaptureSession, didProvide instruction: RoomCaptureSession.Instruction) {
        //
    }
    
    func captureSession(_ session: RoomCaptureSession, didStartWith configuration: RoomCaptureSession.Configuration) {
        //
    }
    
    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: (Error)?) {
        //
        if let error {
            stopSession()
            return
        }
        Task {
            let finalRoom = try! await roomBuilder.capturedRoom(from: data)
            self.finalResults = finalRoom
            capturedRoomArray.append(finalRoom)
        }
    }
}
