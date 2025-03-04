import UIKit

class MyBookingsViewController: UIViewController {
    private var bookings: [DanceClass] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchBookings()
    }

    private func setupUI() {
        title = "Мои записи"
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "bookingCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchBookings() {
        guard let userId = UserDefaults.standard.value(forKey: "userId") as? Int else { return }
        let userIdString = String(userId)

        DatabaseManager.shared.getUserBookings(userId: userIdString) { [weak self] bookings in
            guard let self = self else { return }

            self.bookings = bookings.map {
                DanceClass(
                    id: $0.id,
                    name: $0.className,
                    instructor: $0.instructor,
                    time: $0.time,
                    maxCapacity: 10, // Заглушка, если в БД нет данных
                    description: "Нет описания" // Заглушка, если в БД нет данных
                )
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MyBookingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! CustomTableViewCell
        cell.configure(with: bookings[indexPath.row])
        return cell
    }
}
