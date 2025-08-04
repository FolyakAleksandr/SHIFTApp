import Foundation

// MARK: - Protocol

protocol RegistrationPresenterProtocol: AnyObject {
    func validateInput(firstName: String, lastName: String, birthDate: String, password: String, confirmPassword: String)
    func registerUser(firstName: String, lastName: String, password: String)
}

// MARK: - Presenter

final class RegistrationPresenter {
    // MARK: - Properties

    weak var view: RegistrationViewProtocol?
    private let coreDataManager: CoreDataManagerProtocol

    // MARK: - Init

    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
    }
}

// MARK: - RegistrationPresenterProtocol

extension RegistrationPresenter: RegistrationPresenterProtocol {
    func validateInput(firstName: String, lastName: String, birthDate: String, password: String, confirmPassword: String) {
        guard firstName.count >= 3 else {
            view?.setRegisterButton(enabled: false)
            return
        }

        guard lastName.count >= 3 else {
            view?.setRegisterButton(enabled: false)
            return
        }

        guard !birthDate.isEmpty else {
            view?.setRegisterButton(enabled: false)
            return
        }

        guard password.count >= 6,
              password.rangeOfCharacter(from: .uppercaseLetters) != nil,
              password.rangeOfCharacter(from: .decimalDigits) != nil
        else {
            view?.setRegisterButton(enabled: false)
            return
        }

        guard password == confirmPassword else {
            view?.setRegisterButton(enabled: false)
            return
        }

        view?.setRegisterButton(enabled: true)
    }

    func registerUser(firstName: String, lastName: String, password: String) {
        coreDataManager.saveUser(firstName, lastName, password)
        view?.showMainScreen()
    }
}
