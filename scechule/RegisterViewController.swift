import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let registerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Регистрация"
        view.backgroundColor = .white
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        
        passwordTextField.placeholder = "Пароль (минимум 6 символов)"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .oneTimeCode

        registerButton.setTitle("Зарегистрироваться", for: .normal)
        registerButton.backgroundColor = .systemPink
        registerButton.setTitleColor(.black, for: .normal)
        registerButton.layer.cornerRadius = 10
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func registerTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите email и пароль")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Ошибка регистрации", message: error.localizedDescription)
                return
            }

            self.showAlert(title: "Успешно", message: "Регистрация прошла успешно") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
