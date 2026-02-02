//
//  UIKitDemoView.swift
//  RollingNumberLabelDemo
//
//  Created on 2026-02-02.
//

import SwiftUI
import UIKit
import RollingNumberLabel

// MARK: - SwiftUI Wrapper

struct UIKitDemoView: View {
    var body: some View {
        UIKitDemoViewControllerRepresentable()
            .navigationTitle("UIKit Demo")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
    }
}

struct UIKitDemoViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIKitDemoViewController {
        return UIKitDemoViewController()
    }

    func updateUIViewController(_ uiViewController: UIKitDemoViewController, context: Context) {}
}

// MARK: - UIKit Demo View Controller

final class UIKitDemoViewController: UIViewController {

    // MARK: - Properties

    private var balance: Int = 1_000_000 {
        didSet { updateBalanceLabel() }
    }

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 32
        sv.alignment = .fill
        return sv
    }()

    // Balance Section
    private let balanceContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "잔액"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let balanceLabel = RollingNumberLabel()

    // Simple Number Section
    private let simpleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let simpleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Simple Number"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let simpleNumberLabel = RollingNumberLabel()
    private var simpleNumber: Int = 12345 {
        didSet { updateSimpleNumberLabel() }
    }

    // UILabel Extension Section
    private let extensionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let extensionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "UILabel Extension"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let extensionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    private var extensionNumber: Int = 9999 {
        didSet { updateExtensionLabel() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialValues()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        setupBalanceSection()
        setupSimpleNumberSection()
        setupExtensionSection()
        setupControlsSection()
    }

    private func setupBalanceSection() {
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.textAlignment = .center
        balanceLabel.animationDuration = 0.4

        balanceTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        balanceContainerView.addSubview(balanceTitleLabel)
        balanceContainerView.addSubview(balanceLabel)

        NSLayoutConstraint.activate([
            balanceTitleLabel.topAnchor.constraint(equalTo: balanceContainerView.topAnchor, constant: 16),
            balanceTitleLabel.centerXAnchor.constraint(equalTo: balanceContainerView.centerXAnchor),

            balanceLabel.topAnchor.constraint(equalTo: balanceTitleLabel.bottomAnchor, constant: 8),
            balanceLabel.centerXAnchor.constraint(equalTo: balanceContainerView.centerXAnchor),
            balanceLabel.bottomAnchor.constraint(equalTo: balanceContainerView.bottomAnchor, constant: -16)
        ])

        contentStackView.addArrangedSubview(balanceContainerView)
        contentStackView.addArrangedSubview(createBalanceButtonsStack())
    }

    private func setupSimpleNumberSection() {
        simpleNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        simpleNumberLabel.textAlignment = .center
        simpleNumberLabel.animationDuration = 0.3

        simpleTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        simpleContainerView.addSubview(simpleTitleLabel)
        simpleContainerView.addSubview(simpleNumberLabel)

        NSLayoutConstraint.activate([
            simpleTitleLabel.topAnchor.constraint(equalTo: simpleContainerView.topAnchor, constant: 16),
            simpleTitleLabel.centerXAnchor.constraint(equalTo: simpleContainerView.centerXAnchor),

            simpleNumberLabel.topAnchor.constraint(equalTo: simpleTitleLabel.bottomAnchor, constant: 8),
            simpleNumberLabel.centerXAnchor.constraint(equalTo: simpleContainerView.centerXAnchor),
            simpleNumberLabel.bottomAnchor.constraint(equalTo: simpleContainerView.bottomAnchor, constant: -16)
        ])

        contentStackView.addArrangedSubview(simpleContainerView)
        contentStackView.addArrangedSubview(createSimpleButtonsStack())
    }

    private func setupExtensionSection() {
        extensionLabel.translatesAutoresizingMaskIntoConstraints = false

        extensionTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        extensionContainerView.addSubview(extensionTitleLabel)
        extensionContainerView.addSubview(extensionLabel)

        NSLayoutConstraint.activate([
            extensionTitleLabel.topAnchor.constraint(equalTo: extensionContainerView.topAnchor, constant: 16),
            extensionTitleLabel.centerXAnchor.constraint(equalTo: extensionContainerView.centerXAnchor),

            extensionLabel.topAnchor.constraint(equalTo: extensionTitleLabel.bottomAnchor, constant: 8),
            extensionLabel.centerXAnchor.constraint(equalTo: extensionContainerView.centerXAnchor),
            extensionLabel.bottomAnchor.constraint(equalTo: extensionContainerView.bottomAnchor, constant: -16),
            extensionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])

        contentStackView.addArrangedSubview(extensionContainerView)
        contentStackView.addArrangedSubview(createExtensionButtonsStack())
    }

    private func setupControlsSection() {
        let randomAllButton = createButton(title: "Random All", style: .borderedProminent())
        randomAllButton.addTarget(self, action: #selector(randomAllTapped), for: .touchUpInside)

        let resetButton = createButton(title: "Reset All", style: .bordered())
        resetButton.addTarget(self, action: #selector(resetAllTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [randomAllButton, resetButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually

        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true

        contentStackView.addArrangedSubview(spacer)
        contentStackView.addArrangedSubview(stack)
    }

    private func setupInitialValues() {
        updateBalanceLabel(animated: false)
        updateSimpleNumberLabel(animated: false)
        updateExtensionLabel(animated: false)
    }

    // MARK: - Button Stacks

    private func createBalanceButtonsStack() -> UIStackView {
        let amounts = [-100_000, -10_000, 10_000, 100_000]
        let buttons = amounts.map { amount -> UIButton in
            let button = createButton(title: formatAmount(amount), style: .bordered())
            button.tag = amount
            button.addTarget(self, action: #selector(balanceButtonTapped(_:)), for: .touchUpInside)
            return button
        }

        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }

    private func createSimpleButtonsStack() -> UIStackView {
        let minusButton = createButton(title: "-100", style: .bordered())
        minusButton.addTarget(self, action: #selector(simpleMinusTapped), for: .touchUpInside)

        let plusButton = createButton(title: "+100", style: .bordered())
        plusButton.addTarget(self, action: #selector(simplePlusTapped), for: .touchUpInside)

        let randomButton = createButton(title: "Random", style: .borderedProminent())
        randomButton.addTarget(self, action: #selector(simpleRandomTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [minusButton, plusButton, randomButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }

    private func createExtensionButtonsStack() -> UIStackView {
        let minusButton = createButton(title: "-1000", style: .bordered())
        minusButton.addTarget(self, action: #selector(extensionMinusTapped), for: .touchUpInside)

        let plusButton = createButton(title: "+1000", style: .bordered())
        plusButton.addTarget(self, action: #selector(extensionPlusTapped), for: .touchUpInside)

        let randomButton = createButton(title: "Random", style: .borderedProminent())
        randomButton.addTarget(self, action: #selector(extensionRandomTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [minusButton, plusButton, randomButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }

    // MARK: - Update Labels

    private func updateBalanceLabel(animated: Bool = true) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let numberString = formatter.string(from: NSNumber(value: balance)) ?? "\(balance)"
        let fullString = "\(numberString)원"

        let attributed = NSMutableAttributedString(string: fullString)

        let numberRange = NSRange(location: 0, length: numberString.count)
        attributed.addAttributes([
            .font: UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .heavy),
            .foregroundColor: UIColor.systemGreen
        ], range: numberRange)

        let suffixRange = NSRange(location: numberString.count, length: 1)
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 24, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ], range: suffixRange)

        balanceLabel.setAttributedText(attributed, animated: animated)
    }

    private func updateSimpleNumberLabel(animated: Bool = true) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let numberString = formatter.string(from: NSNumber(value: simpleNumber)) ?? "\(simpleNumber)"

        let attributed = NSAttributedString(
            string: numberString,
            attributes: [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )

        simpleNumberLabel.setAttributedText(attributed, animated: animated)
    }

    private func updateExtensionLabel(animated: Bool = true) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let numberString = formatter.string(from: NSNumber(value: extensionNumber)) ?? "\(extensionNumber)"

        let attributed = NSAttributedString(
            string: "$ \(numberString)",
            attributes: [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold),
                .foregroundColor: UIColor.systemBlue
            ]
        )

        extensionLabel.setAttributedTextWithRolling(attributed, animated: animated, duration: 0.35)
    }

    // MARK: - Actions

    @objc private func balanceButtonTapped(_ sender: UIButton) {
        balance = max(0, balance + sender.tag)
    }

    @objc private func simpleMinusTapped() {
        simpleNumber = max(0, simpleNumber - 100)
    }

    @objc private func simplePlusTapped() {
        simpleNumber += 100
    }

    @objc private func simpleRandomTapped() {
        simpleNumber = Int.random(in: 0...99999)
    }

    @objc private func extensionMinusTapped() {
        extensionNumber = max(0, extensionNumber - 1000)
    }

    @objc private func extensionPlusTapped() {
        extensionNumber += 1000
    }

    @objc private func extensionRandomTapped() {
        extensionNumber = Int.random(in: 0...99999)
    }

    @objc private func randomAllTapped() {
        balance = Int.random(in: 100_000...10_000_000)
        simpleNumber = Int.random(in: 0...99999)
        extensionNumber = Int.random(in: 0...99999)
    }

    @objc private func resetAllTapped() {
        balance = 1_000_000
        simpleNumber = 12345
        extensionNumber = 9999
    }

    // MARK: - Helpers

    private func createButton(title: String, style: UIButton.Configuration) -> UIButton {
        var config = style
        config.title = title
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func formatAmount(_ amount: Int) -> String {
        let prefix = amount >= 0 ? "+" : ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(prefix)\(formatter.string(from: NSNumber(value: amount)) ?? "\(amount)")"
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        UIKitDemoView()
    }
}
