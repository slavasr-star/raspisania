import UIKit
import Firebase
import FirebaseAuth

class ClassDetailViewController: UIViewController {
    private let danceClass: DanceClass
    
    private let nameLabel = UILabel()
    private let instructorLabel = UILabel()
    private let timeLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let enrollButton = UIButton(type: .system)
    
    init(danceClass: DanceClass) {
        self.danceClass = danceClass
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        nameLabel.text = danceClass.name
        instructorLabel.text = "Преподаватель: \(danceClass.instructor)"
        timeLabel.text = "Время: \(danceClass.time)"
        descriptionLabel.text = danceClass.description
        
        enrollButton.setTitle("Записаться", for: .normal)
        enrollButton.addTarget(self, action: #selector(enrollTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, instructorLabel, timeLabel, descriptionLabel, enrollButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func enrollTapped() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Ошибка", message: "Не удалось получить ID пользователя")
            return
        }
        
        DatabaseManager.shared.enrollUser(userId: userId, classId: danceClass.id) { success in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(title: "Успешно", message: "Вы записались на занятие!")
                } else {
                    self.showAlert(title: "Ошибка", message: "Не удалось записаться на занятие")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
