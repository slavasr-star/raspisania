import UIKit

class CustomTableViewCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let instructorLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        instructorLabel.text = nil
        timeLabel.text = nil
    }
    
    private func setupUI() {
        setupLabels()
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, instructorLabel, timeLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    private func setupLabels() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        instructorLabel.font = UIFont.systemFont(ofSize: 14)
        instructorLabel.textColor = .darkGray
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = .gray
    }
    
    func configure(with danceClass: DanceClass) {
        nameLabel.text = danceClass.name
        instructorLabel.text = "Преподаватель: \(danceClass.instructor)"
        timeLabel.text = "Время: \(danceClass.time)"
    }
}
