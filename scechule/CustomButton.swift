import UIKit

class CustomButton: UIButton {
    
    init(title: String, backgroundColor: UIColor = .systemPink, titleColor: UIColor = .black) {
        super.init(frame: .zero)
        setupStyle(title: title, backgroundColor: backgroundColor, titleColor: titleColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle(title: "Кнопка") // Дефолтное название, если используется в Storyboard/XIB
    }
    
    private func setupStyle(title: String, backgroundColor: UIColor = .systemPink, titleColor: UIColor = .black) {
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        self.setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        layer.cornerRadius = 12
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
