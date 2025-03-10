import UIKit
import FirebaseAuth
import FirebaseFirestore

class AdminPanelViewController: UIViewController {
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    private let manageScheduleButton = UIButton(type: .system)
    
    private var classes: [DanceClass] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchClasses()
    }

    private func setupUI() {
        title = "Админ-панель"
        view.backgroundColor = .white

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

        manageScheduleButton.setTitle("Редактировать расписание", for: .normal)
        manageScheduleButton.backgroundColor = UIColor.systemPink
        manageScheduleButton.setTitleColor(.black, for: .normal)
        manageScheduleButton.layer.cornerRadius = 10
        manageScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        manageScheduleButton.addTarget(self, action: #selector(openManageSchedule), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(manageScheduleButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -10),

            addButton.bottomAnchor.constraint(equalTo: manageScheduleButton.topAnchor, constant: -10),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 50),

            manageScheduleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            manageScheduleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            manageScheduleButton.widthAnchor.constraint(equalToConstant: 250),
            manageScheduleButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func fetchClasses() {
        DatabaseManager.shared.getAllClasses { [weak self] fetchedClasses in
            DispatchQueue.main.async {
                self?.classes = fetchedClasses
                self?.tableView.reloadData()
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

    @objc private func openManageSchedule() {
        let vc = ManageScheduleViewController()
        navigationController?.pushViewController(vc, animated: true)
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
            DatabaseManager.shared.deleteClass(id: classToDelete.id) { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        self?.classes.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
}

