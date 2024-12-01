//
//  ViewController.swift
//  RoomScan3D
//
//  Created by Doan Tran Hieu My on 30/9/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    var scannedModels = [ScannedModel]()
    var modelDataCapture: [ModelDataCapture] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton()
        setupTable()
        getFilePaths()
        getListCaptureData()
    }
    
    func setupButton() {
        scanButton.layer.cornerRadius = 20
        scanButton.layer.borderWidth  = 1.0
        scanButton.layer.borderColor = UIColor.blue.cgColor
    }
    
    func setupTable() {
        // set up cell
        tableView.register(UINib(nibName: "ViewCell", bundle: nil), forCellReuseIdentifier: "ViewCell")
        
        //set up table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func getFilePaths(){
        let fm = FileManager.default
        let path = fm.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("capture")
        do{
            let content = try fm.contentsOfDirectory(atPath: path.path)
            print(path)
            for c in content{
                self.scannedModels.append(ScannedModel(filePath: path.appendingPathComponent(c).absoluteString, name: path.appendingPathComponent(c).lastPathComponent))
            }
        }
        catch{
            print(error)
        }
        
    }
    
    @IBAction func goToMenuAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
            let navController = UINavigationController(rootViewController: vc)
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: false, completion: nil)
        }
    }
    
    
    
    func getListCaptureData() {
        if let data =  UserDefaults.standard.data(forKey: "saveData") {
            do {
                let decoder = JSONDecoder()
                self.modelDataCapture = try decoder.decode([ModelDataCapture].self, from: data)
                for item in scannedModels {
                    for idx in 0..<self.modelDataCapture.count {
                        if item.name == self.modelDataCapture[idx].nameUSDZ {
                            self.modelDataCapture[idx].filePath = item.filePath
                        }
                    }
                }
                StoreCapture.shared.dataCapture = self.modelDataCapture
                viewEmpty.isHidden = StoreCapture.shared.dataCapture.count != 0
                tableView.reloadData()
            } catch {
                
            }
        }
    }
    
    func goto3DViewController(index: Int) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Show3DViewController") as? Show3DViewController {
            vc.modelFilePath = modelDataCapture[index].filePath
            let navController = UINavigationController(rootViewController: vc)            
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    
    func goTo2DRoom(index: Int) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Show2DViewController") as? Show2DViewController {
            let finalResult = modelDataCapture[index].data
            vc.capturedRoom = finalResult
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    func deleteByIndex(index: Int) {
        StoreCapture.shared.removeCaptureDataByIndex(index: index)
        modelDataCapture = StoreCapture.shared.dataCapture
        userDefaultData()
        viewEmpty.isHidden = StoreCapture.shared.dataCapture.count != 0
        tableView.reloadData()
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
    
    func shareFileJson(index: Int, type: ModelCaptureType) {
//        if index < modelDataCapture.count {
//            var itemPath = ""
//            switch type {
//            case .JSON:
//                itemPath = modelDataCapture[index].pathFileTxt
//            case .USDZ:
//                itemPath = modelDataCapture[index].filePath
//            case .AIOutput:
//                itemPath = modelDataCapture[index].nameAIOuput
//            }
//            let itemURL = URL(fileURLWithPath: itemPath)
//            let arr = [itemURL]
//            let activityViewController = UIActivityViewController(activityItems: arr, applicationActivities: nil)
//            // Show the share-view
//            switch UIDevice.current.userInterfaceIdiom {
//            case .phone:
//                print("Nothing")
//            case .pad:
//                activityViewController.popoverPresentationController?.sourceView = scannedResultTV
//            default:
//                print("Nothing")
//            }
//            
//            self.present(activityViewController, animated: true, completion: nil)
//        }
    }
    
    func createMenuFolder(index: Int) -> UIMenu {
        let actionShow2D = UIAction(title: "Show 2D", image: UIImage(systemName: "view.2d")) { action in
            print("action add clicked \(index)")
            self.goTo2DRoom(index: index)
        }
        let actionShow3D = UIAction(title: "Show 3D", image: UIImage(systemName: "view.3d")) {action in
            print("action report clicked \(index)")
            self.goto3DViewController(index: index)
        }
        
        let actionDelete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill")) {action in
            print("action report clicked \(index)")
            self.deleteByIndex(index: index)
        }
        
        let shareUSDZ = UIAction(title: "Share USDZ", image: UIImage(systemName: "shared.with.you")) {action in
            print("action report clicked \(index)")
            self.shareFileJson(index: index, type: .USDZ)
        }
        
        let menu = UIMenu(title: "", children: [ actionShow2D, actionShow3D, actionDelete, shareUSDZ])
        return menu
    }
    
    
    @IBAction func goToScanAction(_ sender: Any) {
        if let scanVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ScanViewController") as? ScanViewController {
            let navController = UINavigationController(rootViewController: scanVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelDataCapture.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell") as? ViewCellController {
            let itemDataCapture = modelDataCapture[indexPath.row]
            cell.selectionStyle = .none
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let creationDate = formatter.string(from: itemDataCapture.creationDate)
            cell.setupCell(path: itemDataCapture.filePath, modelName: (itemDataCapture.filePath as NSString).lastPathComponent, createDate: creationDate)

            if #available(iOS 14.0, *) {
                cell.menuButton.showsMenuAsPrimaryAction = true
                cell.menuButton.menu = createMenuFolder(index: indexPath.row)
                cell.menuButton.tintColor = .black
                cell.menuButton.isEnabled = true
            }
            return cell
        }
        
        return UITableViewCell()
    }
}

