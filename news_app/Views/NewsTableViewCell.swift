import UIKit

final class NewsTableViewCell: UITableViewCell {
    static let identifier = "NewsTableViewCell"

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        imageView.layer.shadowRadius = 4
        return imageView
    }()
    
    private let shimmerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            view.layer.cornerRadius = 8
            view.isHidden = true
            return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor.systemGroupedBackground
        contentView.addSubview(containerView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            thumbnailImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            thumbnailImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 60),

            stackView.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with article: NewsArticle) {
            titleLabel.text = article.title
            descriptionLabel.text = article.description

            shimmerView.isHidden = false

            if let urlToImage = article.urlToImage, let url = URL(string: urlToImage) {
                let placeholderImage = UIImage(systemName: "photo")
                thumbnailImageView.image = placeholderImage

                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = 5
                let session = URLSession(configuration: sessionConfig)

                session.dataTask(with: url) { [weak self] data, _, error in
                    DispatchQueue.main.async {
                        self?.shimmerView.isHidden = true
                        if let data = data, error == nil {
                            self?.thumbnailImageView.image = UIImage(data: data) ?? placeholderImage
                        } else {
                            self?.thumbnailImageView.image = placeholderImage
                        }
                    }
                }.resume()
            } else {
                shimmerView.isHidden = true
                thumbnailImageView.image = UIImage(systemName: "photo")
            }
        }
}
