import UIKit

class SettingsViewController: UIViewController {
    
    private let logoutButton = UIButton(type: .system)
    private let pastBookingsButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Настройки"
        view.backgroundColor = .white

        pastBookingsButton.setTitle("Мои прошедшие записи", for: .normal)
        pastBookingsButton.backgroundColor = .systemPink
        pastBookingsButton.setTitleColor(.black, for: .normal)
        pastBookingsButton.layer.cornerRadius = 10
        pastBookingsButton.addTarget(self, action: #selector(openPastBookings), for: .touchUpInside)
        
        logoutButton.setTitle("Выйти", for: .normal)
        logoutButton.backgroundColor = .systemPink
        logoutButton.setTitleColor(.black, for: .normal)
        logoutButton.layer.cornerRadius = 10
        logoutButton.addTarget(self, action: #selector(confirmLogout), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [pastBookingsButton, logoutButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            pastBookingsButton.widthAnchor.constraint(equalToConstant: 250),
            pastBookingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 150),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func openPastBookings() {
        let pastBookingsVC = PastBookingsViewController()
        navigationController?.pushViewController(pastBookingsVC, animated: true)
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
                        navController.setNavigationBarHidden(true, animated: false)
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
