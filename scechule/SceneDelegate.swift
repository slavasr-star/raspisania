import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        DispatchQueue.main.async {
            if Auth.auth().currentUser != nil {
                self.window?.rootViewController = self.createTabBarController()
            } else {
                let loginVC = UINavigationController(rootViewController: LoginViewController())
                
                self.window?.rootViewController = loginVC
            }
            self.window?.makeKeyAndVisible()
        }
    }

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()

        let classesVC = UINavigationController(rootViewController: ClassesListViewController())
        classesVC.tabBarItem = UITabBarItem(title: "Занятия", image: UIImage(systemName: "list.bullet"), tag: 0)

        let bookingsVC = UINavigationController(rootViewController: MyBookingsViewController())
        bookingsVC.tabBarItem = UITabBarItem(title: "Мои записи", image: UIImage(systemName: "bookmark"), tag: 1)

        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 2)

        tabBarController.viewControllers = [classesVC, bookingsVC, settingsVC]
        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {
        guard (Auth.auth().currentUser?.uid) != nil else { return }

        DatabaseManager.shared.autoCompleteTrainings { success in
            if success {
                print("Тренировки завершены и перенесены в прошедшие")
            } else {
                print("Нет новых завершенных тренировок")
            }
        }
    }
}
