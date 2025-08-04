import UIKit

enum MainBuilder {
    static func builder() -> UIViewController {
        let coreDataManger = CoreDataUserStorage.shared
        let apiManager = APIManager.shared
        let presenter = MainPresenter(coreData: coreDataManger, apiManager: apiManager)
        let view = MainViewController(presenter: presenter)
        presenter.view = view

        return view
    }
}
