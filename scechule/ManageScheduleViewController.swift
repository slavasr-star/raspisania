import UIKit
import FirebaseFirestore

class ManageScheduleViewController: UIViewController {
    private let tableView = UITableView()
    private var schedule: [(id: String, name: String, date: String, time: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Управление расписанием"
        setupUI()
        fetchSchedule()
    }

    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "scheduleCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func fetchSchedule() {
        let db = Firestore.firestore()
        db.collection("schedule").getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка загрузки расписания: \(error.localizedDescription)")
                return
            }

            self.schedule = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let date = data["date"] as? String,
                      let time = data["time"] as? String else { return nil }
                return (id: doc.documentID, name: name, date: date, time: time)
            } ?? []

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ManageScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
        let item = schedule[indexPath.row]
        cell.textLabel?.text = "\(item.name) - \(item.date) в \(item.time)"
        return cell
    }
}
