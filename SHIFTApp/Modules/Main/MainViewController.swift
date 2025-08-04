import UIKit

protocol MainViewProtocol: AnyObject {
    func showProducts(_ products: [ProductModel])
    func showError(_ message: String)
    func showGreeting(name: String)
    func showLoading()
    func hideLoading()
}

final class MainViewController: UIViewController {
    // MARK: - Properties

    private let tableView = UITableView()
    private let presenter: MainPresenterProtocol
    private var products: [ProductModel] = []

    private let greetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Приветствие 👨‍💻", for: .normal)
        button.tintColor = .systemGray
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        return button
    }()

    private let loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.fetchProducts()
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        addSubviews()
        setupConstraints()
        setupTableView()
        setupBarButtonItem()
        setupGreetButton()
    }

    private func addSubviews() {
        for item in [tableView, greetButton, loadingView] {
            view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            greetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            greetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: greetButton.topAnchor, constant: -10),

            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
    }

    private func setupBarButtonItem() {
        let logoutImage = UIImage(systemName: "rectangle.portrait.and.arrow.forward")
        let logoutBarButton = UIBarButtonItem(image: logoutImage,
                                              style: .plain,
                                              target: self,
                                              action: #selector(logoutTapped))
        navigationItem.rightBarButtonItem = logoutBarButton
        logoutBarButton.tintColor = .systemGray
    }

    private func setupGreetButton() {
        greetButton.addTarget(self, action: #selector(greetButtonTapped), for: .touchUpInside)
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = products[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = product.title
        content.secondaryText = String(format: "$%.2f", product.price)
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - MainViewProtocol

extension MainViewController: MainViewProtocol {
    func showLoading() {
        loadingView.startAnimating()
        tableView.isHidden = true
    }

    func hideLoading() {
        loadingView.stopAnimating()
        tableView.isHidden = false
    }

    func showProducts(_ products: [ProductModel]) {
        self.products = products
        tableView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showGreeting(name: String) {
        let alert = UIAlertController(title: "Окно приветствия 😇", message: "Здравствуйте, \(name)!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Actions

private extension MainViewController {
    @objc private func greetButtonTapped() {
        presenter.handleGreeting()
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Вы действительно хотите выйти?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let confirmAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let delegate = scene.delegate as? SceneDelegate
            {
                delegate.showRegistrationScreen()
            }
            self.presenter.logout()
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }
}
