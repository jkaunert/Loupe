import UIKit

final class ViewController: UIViewController {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textField = UITextField()
    private let primaryButton = UIButton(type: .system)
    private let toggle = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = "example.root"

        configureTitle()
        configureTextField()
        configureButton()
        configureToggle()
        layoutContent()
    }

    private func configureTitle() {
        titleLabel.text = "Loupe Example"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityIdentifier = "example.title"

        subtitleLabel.text = "Injected observation target"
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.accessibilityIdentifier = "example.subtitle"
    }

    private func configureTextField() {
        textField.placeholder = "Context note"
        textField.borderStyle = .roundedRect
        textField.accessibilityIdentifier = "example.noteField"
    }

    private func configureButton() {
        primaryButton.setTitle("Capture context", for: .normal)
        primaryButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        primaryButton.backgroundColor = .systemBlue
        primaryButton.tintColor = .white
        primaryButton.layer.cornerRadius = 12
        primaryButton.accessibilityIdentifier = "example.primaryButton"
    }

    private func configureToggle() {
        toggle.isOn = true
        toggle.accessibilityIdentifier = "example.toggle"
    }

    private func layoutContent() {
        let toggleRow = UIStackView(arrangedSubviews: [
            makeToggleLabel(),
            toggle,
        ])
        toggleRow.axis = .horizontal
        toggleRow.alignment = .center
        toggleRow.spacing = 16

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            textField,
            primaryButton,
            toggleRow,
        ])
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "example.stack"

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    private func makeToggleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Use compact context"
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "example.toggleLabel"
        return label
    }
}
