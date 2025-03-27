import UIKit
import FirebaseFirestore

class PastBookingsViewController: UIViewController {
    private var pastBookings: [DanceClass] = []
    private let tableView = UITableView()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет прошедших записей"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        DatabaseManager.shared.movePastBookings(userId: userId) { [weak self] success in
            self?.fetchPastBookings()
        }
    }

    private func setupUI() {
        title = "Прошедшие записи"
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "pastBookingCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchPastBookings() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Ошибка: userId не найден в UserDefaults")
            return
        }

        DatabaseManager.shared.getPastBookings(userId: userId) { [weak self] bookings in
            guard let self = self else { return }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Убедись, что формат соответствует хранимым данным

            self.pastBookings = bookings.compactMap {
                guard let date = dateFormatter.date(from: $0.3) else {
                    print("Ошибка конвертации даты: \($0.3)")
                    return nil
                }
                
                return DanceClass(
                    id: $0.0,
                    name: $0.1,
                    instructor: $0.2,
                    time: Timestamp(date: date),
                    maxCapacity: $0.4,
                    description: $0.5
                )
            }

            DispatchQueue.main.async {
                self.emptyLabel.isHidden = !self.pastBookings.isEmpty
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PastBookingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastBookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pastBookingCell", for: indexPath)
        let booking = pastBookings[indexPath.row]
        let date = booking.time.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = dateFormatter.string(from: date)

        cell.textLabel?.text = "\(booking.name) — \(booking.instructor)\n\(dateString)"
        cell.textLabel?.numberOfLines = 2
        return cell
    }
}
