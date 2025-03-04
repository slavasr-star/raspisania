import UIKit

// MARK: - Удобный показ алертов
extension UIViewController {
    func showAlert(title: String, message: String, actionTitle: String = "OK", actionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
            actionHandler?()
        })
        present(alert, animated: true)
    }
}

// MARK: - Упрощенная работа с UITableViewCell
extension UITableView {
    func registerCustomCell<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }

    func dequeueCustomCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            fatalError("Ошибка: Не удалось привести ячейку к \(T.self)")
        }
        return cell
    }
}

// MARK: - UIColor из HEX с поддержкой alpha
extension UIColor {
    convenience init?(hexString: String) { // Изменено название параметра
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6 || hexSanitized.count == 8,
              let rgb = UInt64(hexSanitized, radix: 16) else {
            return nil
        }

        let red = CGFloat((rgb >> (hexSanitized.count == 8 ? 24 : 16)) & 0xFF) / 255.0
        let green = CGFloat((rgb >> (hexSanitized.count == 8 ? 16 : 8)) & 0xFF) / 255.0
        let blue = CGFloat((rgb >> (hexSanitized.count == 8 ? 8 : 0)) & 0xFF) / 255.0
        let alpha = hexSanitized.count == 8 ? CGFloat(rgb & 0xFF) / 255.0 : 1.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
