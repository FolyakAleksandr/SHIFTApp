import Foundation

final class APIManager {
    static let shared = APIManager()

    private init() {}

    func fetchProducts(completion: @escaping (Result<[ProductModel], Error>) -> Void) {
        guard let url = URL(string: "https://fakestoreapi.com/products") else {
            completion(.failure(NSError(domain: "Invalid URl", code: -1)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }

            do {
                let products = try JSONDecoder().decode([ProductModel].self, from: data)
                completion(.success(products))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
