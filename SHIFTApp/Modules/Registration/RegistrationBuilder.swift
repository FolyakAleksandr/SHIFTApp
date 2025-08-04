import UIKit

enum RegistrationBuilder {
    static func builder() -> UIViewController {
        let coreDataManager = CoreDataUserStorage.shared
        
        let presenter = RegistrationPresenter(coreDataManager: coreDataManager)
        let view = RegistrationViewController(presenter: presenter)
        presenter.view = view
        
        return view
    }
}
