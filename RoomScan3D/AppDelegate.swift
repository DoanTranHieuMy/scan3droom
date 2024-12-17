//
//  AppDelegate.swift
//  RoomScan3D
//
//  Created by Doan Tran Hieu My on 30/9/24.
//

import UIKit
import ESTabBarController_swift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        createTabBarNewController(window: window!)
        return true
    }

    
    func createTabBarNewController(window: UIWindow) {
        let tabBarController = ESTabBarController()
    
        let v1 = UINavigationController.init(rootViewController: R.storyboard.main.homeViewController()!)
        let v2 = UINavigationController.init(rootViewController: R.storyboard.main.scanViewController()!)
        let v3 = UINavigationController.init(rootViewController: R.storyboard.main.favouriteViewController()!)
        v1.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Home", image: R.image.iconBarHome(), selectedImage: R.image.iconBarHomeSelected())
        v2.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(), title: nil, image: R.image.iconAddNew(), selectedImage: R.image.iconAddNew())
        v3.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Favorite", image: R.image.iconBarSetting(), selectedImage: R.image.iconBarSetting())
        tabBarController.viewControllers = [v1, v2, v3]
        tabBarController.tabBar.barTintColor = UIColor(red: 93.0, green: 187.0, blue: 83.0, alpha: 1)
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.tintColor = UIColor(rgb: 0x196CAC)
        tabBarController.tabBar.backgroundColor = UIColor(rgb: 0xEBEBEB)
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }


}

