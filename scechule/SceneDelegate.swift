import UIKit
import Firebase
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        FirebaseApp.configure() // Инициализация Firebase

        window = UIWindow(windowScene: windowScene)

        if Auth.auth().currentUser != nil {
            window?.rootViewController = createTabBarController()
        } else {
            let loginVC = UINavigationController(rootViewController: LoginViewController())
            window?.rootViewController = loginVC
        }

        window?.makeKeyAndVisible()
    }

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()

        let classesVC = UINavigationController(rootViewController: ClassesListViewController())
        classesVC.tabBarItem = UITabBarItem(title: "Занятия", image: UIImage(systemName: "list.bullet"), tag: 0)

        let bookingsVC = UINavigationController(rootViewController: MyBookingsViewController())
        bookingsVC.tabBarItem = UITabBarItem(title: "Мои записи", image: UIImage(systemName: "bookmark"), tag: 1)

        tabBarController.viewControllers = [classesVC, bookingsVC]
        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

