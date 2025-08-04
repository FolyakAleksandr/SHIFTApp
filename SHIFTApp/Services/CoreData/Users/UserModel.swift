import Foundation

struct UserModel {
    let id: UUID
    let firstName: String
    let lastName: String
    let password: String
}

extension UserModel {
    init(from entity: UserEntity) {
        self.id = entity.id ?? UUID()
        self.firstName = entity.firstName ?? ""
        self.lastName = entity.lastName ?? ""
        self.password = entity.password ?? ""
    }
}
