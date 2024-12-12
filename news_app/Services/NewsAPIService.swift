import Foundation

final class NewsAPIService {
    
    private let apiKey = "YOUR_API_KEY"
    
    func fetchNews(timeout: TimeInterval = 7, completion: @escaping (Result<[NewsArticle], Error>) -> Void) {
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(apiKey)") else {
                    completion(.failure(NetworkError.invalidURL))
                    return
                }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = timeout
        sessionConfig.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: sessionConfig)

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                completion(.success(newsResponse.articles))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}
