import UIKit

// MARK: - Удобный показ алертов
extension UIViewController {
    func showAlert(title: String, message: String, actions: [(title: String, style: UIAlertAction.Style, handler: (() -> Void)?)] = [("OK", .default, nil)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            alert.addAction(UIAlertAction(title: action.title, style: action.style) { _ in action.handler?() })
        }
        present(alert, animated: true)
    }
}

// MARK: - Упрощенная работа с UITableViewCell
extension UITableView {
    func registerCell<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            fatalError("Ошибка: не удалось dequeuing \(String(describing: cellClass))")
        }
        return cell
    }
}

// MARK: - UIColor из HEX с поддержкой alpha
extension UIColor {
    convenience init?(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")

        guard let rgb = UInt64(hexSanitized, radix: 16) else { return nil }
        
        let length = hexSanitized.count
        let hasAlpha = length == 8

        self.init(
            red: CGFloat((rgb >> (hasAlpha ? 24 : 16)) & 0xFF) / 255.0,
            green: CGFloat((rgb >> (hasAlpha ? 16 : 8)) & 0xFF) / 255.0,
            blue: CGFloat((rgb >> (hasAlpha ? 8 : 0)) & 0xFF) / 255.0,
            alpha: hasAlpha ? CGFloat(rgb & 0xFF) / 255.0 : 1.0
        )
    }
}
