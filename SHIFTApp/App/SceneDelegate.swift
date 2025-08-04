import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        launchRootScreen()
    }

    func showRegistrationScreen() {
        window?.rootViewController = UINavigationController(rootViewController: RegistrationBuilder.builder())
        window?.makeKeyAndVisible()
    }

    private func launchRootScreen() {
        let rootVC: UIViewController

        if CoreDataUserStorage.shared.fetchUser() != nil {
            rootVC = MainBuilder.builder()
        } else {
            rootVC = RegistrationBuilder.builder()
        }

        window?.rootViewController = UINavigationController(rootViewController: rootVC)
        window?.makeKeyAndVisible()
    }
}
