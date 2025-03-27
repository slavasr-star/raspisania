import UIKit
import FirebaseFirestore

class ClassesListViewController: UIViewController {
    private let db = Firestore.firestore()
    private var classes: [DanceClass] = []
    private let tableView = UITableView()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет доступных занятий"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchClasses()
    }

    private func setupUI() {
        title = "Расписание занятий"
        view.backgroundColor = .white

        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "classCell")
        view.addSubview(tableView)

        emptyLabel.frame = view.bounds
        view.addSubview(emptyLabel)
    }

    private func fetchClasses() {
        db.collection("classes").getDocuments(source: .default) { [weak self] (snapshot, error) in
            if let error = error {
                print("Ошибка загрузки данных: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            let fetchedClasses = documents.compactMap { doc -> DanceClass? in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let instructor = data["instructor"] as? String,
                      let timestamp = data["time"] as? Timestamp,
                      let maxCapacity = data["maxCapacity"] as? Int,
                      let description = data["description"] as? String else { return nil }
                
                return DanceClass(id: doc.documentID, name: name, instructor: instructor, time: timestamp, maxCapacity: maxCapacity, description: description)
            }

            DispatchQueue.main.async {
                self?.classes = fetchedClasses
                self?.tableView.reloadData()
                self?.emptyLabel.isHidden = !fetchedClasses.isEmpty
            }
        }
    }
}

extension ClassesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! CustomTableViewCell
        let danceClass = classes[indexPath.row]
        cell.configure(with: danceClass)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = ClassDetailViewController(danceClass: classes[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
