import UIKit

protocol RegistrationViewProtocol: AnyObject {
    func setRegisterButton(enabled: Bool)
    func showMainScreen()
}

final class RegistrationViewController: UIViewController {
    // MARK: - Properties

    private let presenter: RegistrationPresenterProtocol

    // MARK: - UI Elements

    private lazy var firstNameField = CustomTextField(
        placeholder: "Имя",
        label: "От 3 букв, только кириллица"
    )

    private lazy var lastNameField = CustomTextField(
        placeholder: "Фамилия",
        label: "От 3 букв, только кириллица"
    )

    private lazy var birthDateCustomField = CustomTextField(
        placeholder: "Дата рождения",
        label: "Выберите из календаря"
    )

    private lazy var passwordField = CustomTextField(
        placeholder: "Пароль",
        label: "6+ символов, заглавная и цифра",
        isSecure: true
    )

    private lazy var confirmPasswordField = CustomTextField(
        placeholder: "Повторите пароль",
        label: "Пароли должны совпадать",
        isSecure: true
    )

    private lazy var registerButton: UIButton = {
        let button = makeButton(title: "Регистрация")
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.maximumDate = Date()
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    // MARK: - Init

    init(presenter: RegistrationPresenterProtocol) {
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
        setupUI()
    }

    // MARK: - setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground
        addSubviews()
        setupConstraints()
        setupKeyboardObservers()
        setupTapGesture()
        setupBirthDatePicker()
        setupTextFieldTargets()
    }

    private func addSubviews() {
        for item in [firstNameField, lastNameField, birthDateCustomField, passwordField, confirmPasswordField, registerButton] {
            stackView.addArrangedSubview(item)
        }

        view.addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func makeToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        let done = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(didTapDoneDatePicker))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spacer, done], animated: false)
        return toolbar
    }

    private func setupBirthDatePicker() {
        birthDateCustomField.textField.inputView = datePicker
        birthDateCustomField.textField.inputAccessoryView = makeToolbar()
        birthDateCustomField.textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }

    private func setupTextFieldTargets() {
        for item in [firstNameField, lastNameField, passwordField, confirmPasswordField] {
            item.textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }
}

// MARK: - RegistrationViewProtocol

extension RegistrationViewController: RegistrationViewProtocol {
    func setRegisterButton(enabled: Bool) {
        registerButton.isEnabled = enabled
        registerButton.alpha = enabled ? 1.0 : 0.5
    }

    func showMainScreen() {
        let coreData = CoreDataUserStorage.shared
        let apiManager = APIManager.shared
        let mainPresenter = MainPresenter(coreData: coreData, apiManager: apiManager)

        let mainVC = MainViewController(presenter: mainPresenter)
        mainPresenter.view = mainVC

        navigationController?.setViewControllers([mainVC], animated: true)
    }
}

// MARK: - UI Setup

private extension RegistrationViewController {
    func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
}

// MARK: - Actions

private extension RegistrationViewController {
    @objc func dateChanged() {
        birthDateCustomField.textField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc func didTapDoneDatePicker() {
        birthDateCustomField.textField.text = dateFormatter.string(from: datePicker.date)
        birthDateCustomField.textField.resignFirstResponder()
    }

    @objc func registerButtonTapped() {
        guard let firstName = firstNameField.textField.text,
              let lastName = lastNameField.textField.text,
              let password = passwordField.textField.text else { return }
        presenter.registerUser(firstName: firstName, lastName: lastName, password: password)
    }

    @objc func textFieldChanged(textField: UITextField) {
        presenter.validateInput(
            firstName: firstNameField.textField.text ?? "",
            lastName: lastNameField.textField.text ?? "",
            birthDate: birthDateCustomField.textField.text ?? "",
            password: passwordField.textField.text ?? "",
            confirmPassword: confirmPasswordField.textField.text ?? ""
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2.5)
        }
    }

    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
