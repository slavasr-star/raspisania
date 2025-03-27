import UIKit
import FirebaseAuth
import FirebaseFirestore

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
        tableView.isHidden = true

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchBookings() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Ошибка: userId не найден")
            return
        }

        print("Запрашиваем записи для userId: \(userId)")

        DatabaseManager.shared.getUserBookings(userId: userId) { [weak self] bookings in
            guard let self = self else { return }

            print("Полученные записи из базы: \(bookings)")

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Подстрой под свой формат даты

            self.bookings = bookings.compactMap {
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
                self.tableView.isHidden = self.bookings.isEmpty
                UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                }, completion: nil)

                print("Обновлено \(self.bookings.count) записей, tableView.isHidden = \(self.tableView.isHidden)")
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
