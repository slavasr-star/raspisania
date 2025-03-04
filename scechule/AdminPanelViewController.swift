import UIKit

class AdminPanelViewController: UIViewController {
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    private var classes: [DanceClass] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchClasses()
    }

    private func isAdmin() -> Bool {
        return UserDefaults.standard.bool(forKey: "isAdmin")
    }

    private func setupUI() {
        title = "Админ-панель"
        view.backgroundColor = .white

        if !isAdmin() {
            navigationController?.popViewController(animated: true)
            return
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "classCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        addButton.setTitle("Добавить занятие", for: .normal)
        addButton.backgroundColor = UIColor.systemPink
        addButton.setTitleColor(.black, for: .normal)
        addButton.layer.cornerRadius = 10
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addClassTapped), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -10),

            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func fetchClasses() {
        DatabaseManager.shared.getAllClasses { [weak self] fetchedClasses in
            guard let self = self else { return }
            self.classes = fetchedClasses

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    @objc private func addClassTapped() {
        let addVC = AddEditClassViewController()
        addVC.onClassSaved = { [weak self] in
            self?.fetchClasses()
        }
        navigationController?.pushViewController(addVC, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AdminPanelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
        cell.textLabel?.text = classes[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editVC = AddEditClassViewController(classToEdit: classes[indexPath.row])
        editVC.onClassSaved = { [weak self] in
            self?.fetchClasses()
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let classToDelete = classes[indexPath.row]
            let classId = classToDelete.id // Просто присваиваем
            
            DatabaseManager.shared.deleteClass(id: classId) { success in
                if success {
                    DispatchQueue.main.async {
                        self.classes.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    print("❌ Ошибка при удалении занятия")
                }
            }
        }
    }
}
