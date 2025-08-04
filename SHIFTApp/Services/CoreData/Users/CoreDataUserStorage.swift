import CoreData
import UIKit

// MARK: - Protocol

protocol CoreDataManagerProtocol {
    func saveUser(_ firstName: String, _ lastName: String, _ password: String)
    func fetchUser() -> UserModel?
    func deleteUser()
}

// MARK: - CoreDataManager

final class CoreDataUserStorage: CoreDataManagerProtocol {
    static let shared = CoreDataUserStorage()

    // MARK: - Core Data Stack

    private let backgroundContext: NSManagedObjectContext = CoreDataStack.shared.backgroundContext

    private init() {}

    // MARK: - Save

    func saveUser(_ firstName: String, _ lastName: String, _ password: String) {
        let user = UserEntity(context: backgroundContext)
        user.id = UUID()
        user.firstName = firstName
        user.lastName = lastName
        user.password = password

        do {
            try backgroundContext.save()
            print("✅ User saved")
        } catch {
            print("🚫 Failed save")
        }
    }

    func fetchUser() -> UserModel? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()

        do {
            if let user = try backgroundContext.fetch(request).first {
                return UserModel(from: user)
            }
        } catch {
            print("🚫 Failed to fetch user: \(error.localizedDescription)")
        }
        return nil
    }

    // MARK: - Delete

    /// Не уверен, что это хорошая идея - удалять пользователя на разлогин. Может, какой нибудь другой функционал добавить для этого?
    /// А то как то жестко выходить
    /// У тебя как раз есть поле с айдишниками.
    /// Еще можно отслеживать поле CurrentlyInUse: Bool - если несколько пользователей в базе лежат локальной, то мы будем знать, какой сейчас используется, чтоб удалить его
    func deleteUser() {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()

        do {
            let users = try backgroundContext.fetch(request)
            for user in users {
                backgroundContext.delete(user)
            }
            try backgroundContext.save()
        } catch {
            print("Ошибка при удалении пользователя: \(error)")
        }
    }
}
