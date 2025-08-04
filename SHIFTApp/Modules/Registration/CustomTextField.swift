import UIKit

final class CustomTextField: UIView {
    // MARK: - Properties

    let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(placeholder: String, label: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        hintLabel.text = label
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        addViews()
        setupConstraints()
        setupObservers()
    }

    private func addViews() {
        [textField, hintLabel].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),

            hintLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            hintLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupObservers() {
        textField.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
    }

    // MARK: - Actions

    @objc private func didBeginEditing() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.hintLabel.alpha = 1
        }
    }

    @objc private func didEndEditing() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.hintLabel.alpha = 0
        }
    }
}
