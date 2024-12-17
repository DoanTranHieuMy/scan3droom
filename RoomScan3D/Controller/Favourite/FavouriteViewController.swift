//
//  FavouriteViewController.swift
//  RoomScan3D
//
//  Created by Vuong Doan on 17/12/24.
//

import Foundation
import UIKit

class FavouriteViewController: UIViewController {
    
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var tableView: UITableView!
    var scannedModels = [ScannedModel]()
    var modelDataCapture: [ModelDataCapture] = []
    var allDataCapture: [ModelDataCapture] = []
    let fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFilePaths()
        getListCaptureData()
        setupTable()
    }
    
    func userDefaultData() {
        let dataCapture = self.allDataCapture
        do {
            let encoder = JSONEncoder()
            let dataSave = try encoder.encode(dataCapture)
            UserDefaults.standard.setValue(dataSave, forKey: "saveData")
        } catch {
            
        }
    }
    
    func getFilePaths(){
        let fm = FileManager.default
        let path = fm.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("capture")
        do{
            let content = try fm.contentsOfDirectory(atPath: path.path)
            for c in content{
                self.scannedModels.append(ScannedModel(filePath: path.appendingPathComponent(c).absoluteString, name: path.appendingPathComponent(c).lastPathComponent))
            }
        }
        catch{
            print(error)
        }
        
    }
    
    func getListCaptureData() {
        if let data =  UserDefaults.standard.data(forKey: "saveData") {
            do {
                let decoder = JSONDecoder()
                self.allDataCapture = try decoder.decode([ModelDataCapture].self, from: data)
                self.modelDataCapture = allDataCapture.filter{ $0.isFavorite }
                
                for item in scannedModels {
                    for idx in 0..<self.modelDataCapture.count {
                        if item.name == self.modelDataCapture[idx].nameUSDZ { //name    String    "A6C39B357-0337-4537-A474-720A53059324.usdz"
                            self.modelDataCapture[idx].url = URL(string: item.filePath)
                            self.modelDataCapture[idx].filePath = item.filePath
                        }
                    }
                }
                
                viewEmpty.isHidden = self.modelDataCapture.count != 0
                tableView.reloadData()
            } catch {
                
            }
        }
    }
    
    func setupTable() {
        // set up cell
        tableView.register(UINib(nibName: "ViewCell", bundle: nil), forCellReuseIdentifier: "ViewCell")
        
        //set up table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
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
        
        let shareUSDZ = UIAction(title: "Share USDZ", image: UIImage(systemName: "shared.with.you")) {action in
            print("action report clicked \(index)")
            self.shareFileJson(index: index, type: .USDZ)
        }
        
        let menu = UIMenu(title: "", children: [ actionShow2D, actionShow3D, shareUSDZ])
        return menu
    }
    
    func shareFileJson(index: Int, type: ModelCaptureType) {
        if let url = self.modelDataCapture[index].url {
            let arr = [url]
            let activityViewController = UIActivityViewController(activityItems: arr, applicationActivities: nil)
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                print("Nothing")
            case .pad:
                activityViewController.popoverPresentationController?.sourceView = tableView
                
            @unknown default:
                print("Nothing")
            }
            // Show the share-view
            self.present(activityViewController, animated: true, completion: nil)
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
}

extension FavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelDataCapture.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell") as? ViewCellController {
            let itemDataCapture = modelDataCapture[indexPath.row]
            cell.selectionStyle = .none
            cell.delegate = self
            cell.setupCell(itemDataCapture: itemDataCapture, index: indexPath.row)

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

extension FavouriteViewController: ViewCellControllerProtocol {
    func clickFavoriteButton(index: Int) {
        let dataFavorite = modelDataCapture[index].isFavorite
        modelDataCapture[index].isFavorite = !dataFavorite
        changeDataUserDefaults(itemModelDataCapture: modelDataCapture[index])
        getListCaptureData()
    }
    
    func changeDataUserDefaults(itemModelDataCapture: ModelDataCapture) {
        let idx = self.allDataCapture.firstIndex(where: { $0.nameUSDZ.uppercased() == itemModelDataCapture.nameUSDZ.uppercased()})
        if let index = idx {
            self.allDataCapture[index].isFavorite = itemModelDataCapture.isFavorite
        }
        userDefaultData()
    }
}
