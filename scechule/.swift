//
//  TabBarController 2.swift
//  scechule
//
//  Created by Миласлава Романова on 06.03.2025.
//


import UIKit
import FirebaseAuth

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTabs), name: .AuthStateDidChange, object: nil)
        
        AuthManager.shared.isAdmin { isAdmin in
            DispatchQueue.main.async {
                self.setupTabs(isAdmin: isAdmin)
            }
        }
    }
    
    private func setupTabs(isAdmin: Bool) {
        let classesListVC = UINavigationController(rootViewController: ClassesListViewController())
        classesListVC.tabBarItem = UITabBarItem(title: "Занятия", image: UIImage(systemName: "list.bullet"), tag: 0)
        
        let myBookingsVC = UINavigationController(rootViewController: MyBookingsViewController())
        myBookingsVC.tabBarItem = UITabBarItem(title: "Мои записи", image: UIImage(systemName: "bookmark"), tag: 1)
        
        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 2)
        
        var viewControllersList = [classesListVC, myBookingsVC, settingsVC]
        
        if isAdmin {
            let adminPanelVC = UINavigationController(rootViewController: AdminPanelViewController())
            adminPanelVC.tabBarItem = UITabBarItem(title: "Админ", image: UIImage(systemName: "person.fill"), tag: 3)
            viewControllersList.append(adminPanelVC)
        }
        
        self.viewControllers = viewControllersList
    }
    
    @objc private func refreshTabs() {
        AuthManager.shared.isAdmin { isAdmin in
            DispatchQueue.main.async {
                self.setupTabs(isAdmin: isAdmin)
            }
        }
    }
}
