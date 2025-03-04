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
              let time = timeTextField.text, !time.isEmpty else {
            print("Заполните все поля")
            return
        }

        let description = descriptionTextView.text == placeholderText ? "" : descriptionTextView.text ?? ""

        saveButton.isEnabled = false
        activityIndicator.startAnimating()

        DispatchQueue.global(qos: .userInitiated).async {
            if let classToEdit = self.classToEdit {
                let updatedClass = DanceClass(
                    id: classToEdit.id,
                    name: name,
                    instructor: instructor,
                    time: time,
                    maxCapacity: classToEdit.maxCapacity,
                    description: description
                )
                DatabaseManager.shared.updateClass(updatedClass, completion: <#(Bool) -> Void#>)
            } else {
                let newClass = DanceClass(id: UUID().uuidString, name: name, instructor: instructor, time: time, maxCapacity: 10, description: description)
                DatabaseManager.shared.addClass(
                    name: newClass.name,
                    instructor: newClass.instructor,
                    time: newClass.time,
                    maxCapacity: newClass.maxCapacity,
                    description: newClass.description, completion: <#(Bool) -> Void#>
                )
            }

            DispatchQueue.main.async {
                self.onClassSaved?()
                self.navigationController?.popViewController(animated: true)
                self.activityIndicator.stopAnimating()
                self.saveButton.isEnabled = true
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension AddEditClassViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 200
    }
}
