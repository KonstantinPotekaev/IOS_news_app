import UIKit

final class NewsListViewController: UIViewController {
    private let tableView = UITableView()
    private var articles: [NewsArticle] = []
    private let newsService = NewsAPIService()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNews()
    }

    private func configureUI() {
        title = "News"
        view.backgroundColor = .systemGroupedBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        tableView.refreshControl = refreshControl

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchNews() {
            newsService.fetchNews(timeout: 7) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let articles):
                        self?.articles = articles
                        self?.tableView.reloadData()
                    case .failure(let error):
                        self?.showErrorAlert(message: "Failed to refresh news: \(error.localizedDescription)")
                    }
                    self?.refreshControl.endRefreshing()
                }
            }
        }


    @objc private func refreshNews() {
        fetchNews()
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


extension NewsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: articles[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        guard let url = URL(string: article.url) else { return }
        let webVC = WebViewController(url: url)
        navigationController?.pushViewController(webVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, completionHandler in
                guard let self = self else {
                    completionHandler(false)
                    return
                }

                let article = self.articles[indexPath.row]
                let activityVC = UIActivityViewController(activityItems: [article.url], applicationActivities: nil)
                self.present(activityVC, animated: true) {
                    completionHandler(true)
                }
            }
            shareAction.backgroundColor = .systemBlue
            let configuration = UISwipeActionsConfiguration(actions: [shareAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
}
