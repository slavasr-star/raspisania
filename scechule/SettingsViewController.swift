import UIKit

class SettingsViewController: UIViewController {
    
    private let logoutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Настройки"
        view.backgroundColor = .white

        logoutButton.setTitle("Выйти", for: .normal)
        logoutButton.backgroundColor = .systemPink
        logoutButton.setTitleColor(.black, for: .normal)
        logoutButton.layer.cornerRadius = 10
        logoutButton.addTarget(self, action: #selector(confirmLogout), for: .touchUpInside)

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    @objc private func confirmLogout() {
        let alert = UIAlertController(title: "Выход",
                                      message: "Вы уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        
        present(alert, animated: true)
    }

    private func performLogout() {
        AuthManager.shared.logout { success, error in
            if success {
                DispatchQueue.main.async {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        let loginVC = LoginViewController()
                        let navController = UINavigationController(rootViewController: loginVC)
                        navController.setNavigationBarHidden(true, animated: false) // Скрываем навбар на экране входа
                        window.rootViewController = navController
                        window.makeKeyAndVisible()
                    }
                }
            } else {
                print("Ошибка выхода: \(error ?? "Неизвестная ошибка")")
            }
        }
    }
}
