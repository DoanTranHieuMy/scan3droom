//
//  HomeViewController.swift
//  RoomScan3D
//
//  Created by Doan Tran Hieu My on 30/9/24.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    var scannedModels = [ScannedModel]()
    var modelDataCapture: [ModelDataCapture] = []
    var filterData: [ModelDataCapture] = []
    let fileManager = FileManager.default
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.iconBarSetting()!, style: .plain, target: self, action: #selector(goToSetting))
        getFilePaths()
        getListCaptureData()
        setSearchBarUI()
        setupTable()
    }
    
    func setSearchBarUI() {
        self.searchBar.placeholder = "Search"
        self.searchBar.delegate = self
    }
    
    func setupTable() {
        // set up cell
        filterData = modelDataCapture
        tableView.register(UINib(nibName: "ViewCell", bundle: nil), forCellReuseIdentifier: "ViewCell")
        
        //set up table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
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
    
    
    @objc func goToSetting() {
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
                        if item.name == self.modelDataCapture[idx].nameUSDZ { //name    String    "A6C39B357-0337-4537-A474-720A53059324.usdz"
                            self.modelDataCapture[idx].url = URL(string: item.filePath)
                            self.modelDataCapture[idx].filePath = item.filePath
                        }
                    }
                }
                StoreCapture.shared.dataCapture = self.modelDataCapture
                viewEmpty.isHidden = StoreCapture.shared.dataCapture.count != 0
                filterData = self.modelDataCapture
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
        if let url = self.filterData[index].url {
            self.deleteItemInFileManagerByUrl(url: url)
        }
        StoreCapture.shared.removeCaptureDataByIndex(index: index)
        modelDataCapture = StoreCapture.shared.dataCapture
        filterData = modelDataCapture
        userDefaultData()
        viewEmpty.isHidden = StoreCapture.shared.dataCapture.count != 0
        tableView.reloadData()
    }
    
    // Delete Item In Dictionary Document By Url
    private func deleteItemInFileManagerByUrl(url: URL) {
        do {
            if fileManager.fileExists(atPath: url.path) {
                // Delete file
                try fileManager.removeItem(at: url)
            } else {
                print("File does not exist")
            }
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
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
        if let url = self.filterData[index].url {
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
        
        let actionRename = UIAction(title: "Rename", image: UIImage(systemName: "pencil")) {action in
            print("action report clicked \(index)")
            self.renameAudioByIndex(index: index)
        }
        
        let shareUSDZ = UIAction(title: "Share USDZ", image: UIImage(systemName: "shared.with.you")) {action in
            print("action report clicked \(index)")
            self.shareFileJson(index: index, type: .USDZ)
        }
        
        let menu = UIMenu(title: "", children: [ actionShow2D, actionShow3D, actionRename, actionDelete, shareUSDZ])
        return menu
    }
    
    func renameAudioByIndex(index: Int) {
        guard let itemURL = filterData[index].url else { return }
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "Rename", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let cancelSheet = UIAlertAction(title: "Cancel",
                                        style: .default, handler: nil)
        
        let doneSheet = UIAlertAction(title: "Done",
                                      style: .default) { [weak self] _ in
                                        guard let this = self else { return }
                                        guard let name = inputTextField?.text else { return }
            this.changeName(url: itemURL, nameChange: name, index: index)
                                        
        }
        
        alert.addAction(cancelSheet)
        alert.addAction(doneSheet)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Change Name"
            inputTextField = textField
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeName(url: URL, nameChange: String, index: Int) {
        savingFileForFileDocument(pathAudio: url.path, name: nameChange, index: index)
        tableView.reloadData()
    }
    
    // Saving File From to newPath
    public func savingFileForFileDocument(pathAudio: String, name: String, index: Int) {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("capture")
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        // create new Path
        let newPath = path + "/\(name).usdz"
        // Move oldPath to newPath
        do {
            try fileManager.moveItem(atPath: pathAudio, toPath: newPath)
            let idx = self.modelDataCapture.firstIndex(where: { $0.nameUSDZ.uppercased() == filterData[index].nameUSDZ.uppercased()})
            if let index = idx {
                self.modelDataCapture[index].nameUSDZ = "\(name).usdz"
                self.modelDataCapture[index].url = URL(fileURLWithPath: newPath).absoluteURL
                self.modelDataCapture[index].filePath = URL(fileURLWithPath: newPath).absoluteString
                StoreCapture.shared.dataCapture = self.modelDataCapture
                userDefaultData()
            }
            filterData[index].nameUSDZ = "\(name).usdz"
            filterData[index].url = URL(fileURLWithPath: newPath).absoluteURL
            filterData[index].filePath = URL(fileURLWithPath: newPath).absoluteString
            
        } catch {
            print("error")
            return
        }
    }
    
    
    @IBAction func goToScanAction(_ sender: Any) {
        if let scanVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ScanViewController") as? ScanViewController {
            let navController = UINavigationController(rootViewController: scanVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
        
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell") as? ViewCellController {
            let itemDataCapture = filterData[indexPath.row]
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

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData = []
        
        if searchText == "" {
            filterData = modelDataCapture
        }
        
        for item in modelDataCapture {
            if item.nameUSDZ.uppercased().contains(searchText.uppercased()) {
                filterData.append(item)
            }
        }
        
        self.tableView.reloadData()
    }
}

extension HomeViewController: ViewCellControllerProtocol {
    func clickFavoriteButton(index: Int) {
        let dataFavorite = filterData[index].isFavorite
        filterData[index].isFavorite = !dataFavorite
        print("filterData[index].isFavorite \(filterData[index].isFavorite)")
        
        changeDataUserDefaults(itemModelDataCapture: filterData[index])
        
        self.tableView.reloadData()
    }
    
    func changeDataUserDefaults(itemModelDataCapture: ModelDataCapture) {
        let idx = self.modelDataCapture.firstIndex(where: { $0.nameUSDZ.uppercased() == itemModelDataCapture.nameUSDZ.uppercased()})
        if let index = idx {
            self.modelDataCapture[index].isFavorite = itemModelDataCapture.isFavorite
        }
        StoreCapture.shared.dataCapture = self.modelDataCapture
        userDefaultData()
    }
}

