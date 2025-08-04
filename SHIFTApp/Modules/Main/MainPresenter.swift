import UIKit

// MARK: - Protocol

protocol MainPresenterProtocol: AnyObject {
    func fetchProducts()
    func handleGreeting()
    func logout()
}

// MARK: - Presenter

final class MainPresenter {
    // MARK: - Properties

    weak var view: MainViewProtocol?

    private let coreData: CoreDataManagerProtocol
    private let apiManager: APIManager

    // MARK: - Init

    init(coreData: CoreDataManagerProtocol, apiManager: APIManager) {
        self.coreData = coreData
        self.apiManager = apiManager
    }
}

// MARK: - MainPresenterProtocol

extension MainPresenter: MainPresenterProtocol {
    func fetchProducts() {
        view?.showLoading()

        apiManager.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                switch result {
                case .success(let products):
                    self?.view?.showProducts(products)
                case .failure(let error):
                    self?.view?.showError(error.localizedDescription)
                }
            }
        }
    }

    func handleGreeting() {
        if let user = coreData.fetchUser() {
            view?.showGreeting(name: user.firstName)
        } else {
            view?.showError("Имя пользователя не найдено.")
        }
    }

    func logout() {
        coreData.deleteUser()
    }
}
