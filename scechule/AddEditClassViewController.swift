import UIKit

class AddEditClassViewController: UIViewController {
    private var classToEdit: DanceClass?
    var onClassSaved: (() -> Void)?
    
    private let nameTextField = UITextField()
    private let instructorTextField = UITextField()
    private let timeTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let saveButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let placeholderText = "Введите описание занятия..."
    
    init(classToEdit: DanceClass? = nil) {
        self.classToEdit = classToEdit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureToDismissKeyboard()
        
        if let classToEdit = classToEdit {
            populateFields(with: classToEdit)
        } else {
            descriptionTextView.text = placeholderText
            descriptionTextView.textColor = .lightGray
        }
    }
    
    private func setupUI() {
        title = classToEdit == nil ? "Добавить занятие" : "Редактировать занятие"
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [nameTextField, instructorTextField, timeTextField, descriptionTextView, saveButton, activityIndicator])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        setupTextFields()
        setupDescriptionTextView()
        setupSaveButton()
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            instructorTextField.heightAnchor.constraint(equalToConstant: 40),
            timeTextField.heightAnchor.constraint(equalToConstant: 40),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            activityIndicator.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupTextFields() {
        [nameTextField, instructorTextField, timeTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.backgroundColor = .white
        }
        nameTextField.placeholder = "Название занятия"
        instructorTextField.placeholder = "Имя преподавателя"
        timeTextField.placeholder = "Время"
    }
    
    private func setupDescriptionTextView() {
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.delegate = self
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .systemPink
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func populateFields(with danceClass: DanceClass) {
        nameTextField.text = danceClass.name
        instructorTextField.text = danceClass.instructor
        timeTextField.text = danceClass.time
        descriptionTextView.text = danceClass.description
        descriptionTextView.textColor = .black
    }
    
    private func setupGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let instructor = instructorTextField.text, !instructor.isEmpty,
              let timeString = timeTextField.text, !timeString.isEmpty else {
            print("Заполните все поля")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // Настроить под твой формат времени
        guard let date = formatter.date(from: timeString) else {
            print("Некорректный формат даты")
            return
        }
        let timestamp = Timestamp(date: date)
        
        let description = descriptionTextView.text == placeholderText ? "" : descriptionTextView.text ?? ""
        
        saveButton.isEnabled = false
        activityIndicator.startAnimating()
        
        Task {
            var success = false
            
            if let classToEdit = self.classToEdit {
                success = await withCheckedContinuation { continuation in
                    DatabaseManager.shared.updateClass(
                        id: classToEdit.id,
                        name: name,
                        instructor: instructor,
                        time: timestamp, // Теперь передаём Timestamp
                        maxCapacity: classToEdit.maxCapacity,
                        description: description
                    ) { isSuccess in
                        continuation.resume(returning: isSuccess)
                    }
                }
            } else {
                let newClass = DanceClass(
                    id: UUID().uuidString,
                    name: name,
                    instructor: instructor,
                    time: timestamp, // Timestamp вместо строки
                    maxCapacity: 20,
                    description: description
                )
                success = await DatabaseManager.shared.addClass(newClass)
            }
            
            DispatchQueue.main.async {
                self.saveButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                if success {
                    print("Класс успешно сохранен")
                    self.onClassSaved?()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Ошибка при сохранении класса")
                }
            }
        }
    }
}
