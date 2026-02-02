//
//  UsageExample.swift
//  SlotLabel
//
//  사용 예제
//

import UIKit

// MARK: - 예제 1: RollingNumberLabel 직접 사용

class ExampleViewController: UIViewController {

    private let rollingLabel = RollingNumberLabel()
    private var currentAmount: Int = 1_000_000

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRollingLabel()
        setupButtons()
    }

    private func setupRollingLabel() {
        rollingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rollingLabel)

        NSLayoutConstraint.activate([
            rollingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rollingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rollingLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        // 초기값 설정 (애니메이션 없이)
        let initialText = createAttributedString(for: currentAmount)
        rollingLabel.setAttributedText(initialText, animated: false)
    }

    private func setupButtons() {
        let increaseButton = UIButton(type: .system)
        increaseButton.setTitle("금액 증가", for: .normal)
        increaseButton.addTarget(self, action: #selector(increaseAmount), for: .touchUpInside)

        let decreaseButton = UIButton(type: .system)
        decreaseButton.setTitle("금액 감소", for: .normal)
        decreaseButton.addTarget(self, action: #selector(decreaseAmount), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [decreaseButton, increaseButton])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: rollingLabel.bottomAnchor, constant: 40)
        ])
    }

    @objc private func increaseAmount() {
        // 1,000,000원 → 1,100,100원
        currentAmount += 100_100
        updateLabel()
    }

    @objc private func decreaseAmount() {
        currentAmount = max(0, currentAmount - 100_100)
        updateLabel()
    }

    private func updateLabel() {
        let newText = createAttributedString(for: currentAmount)
        // 애니메이션과 함께 업데이트
        rollingLabel.setAttributedText(newText, animated: true)
    }

    private func createAttributedString(for amount: Int) -> NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","

        let amountString = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        let fullString = "\(amountString)원"

        let attributedString = NSMutableAttributedString(string: fullString)

        // 숫자 부분 스타일
        let numberRange = NSRange(location: 0, length: amountString.count)
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: UIColor.black
        ], range: numberRange)

        // "원" 스타일
        let unitRange = NSRange(location: amountString.count, length: 1)
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 24, weight: .regular),
            .foregroundColor: UIColor.gray
        ], range: unitRange)

        return attributedString
    }
}

// MARK: - 예제 2: 기존 UILabel에 Extension 사용

class ExampleWithExtensionViewController: UIViewController {

    private let priceLabel = UILabel()
    private var currentPrice: Int = 1_000_000

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabel()
    }

    private func setupLabel() {
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            priceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            priceLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        // 초기값 설정
        let initialText = createPriceAttributedString(currentPrice)
        priceLabel.setAttributedTextWithRolling(initialText, animated: false)
    }

    func updatePrice(to newPrice: Int) {
        currentPrice = newPrice
        let newText = createPriceAttributedString(newPrice)

        // 기존 UILabel에서 롤링 애니메이션 사용
        priceLabel.setAttributedTextWithRolling(newText, animated: true, duration: 0.4)
    }

    private func createPriceAttributedString(_ price: Int) -> NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let priceString = formatter.string(from: NSNumber(value: price)) ?? "\(price)"

        return NSAttributedString(
            string: "\(priceString)원",
            attributes: [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold),
                .foregroundColor: UIColor.systemBlue
            ]
        )
    }
}

// MARK: - 예제 3: 다양한 형식 지원

class AdvancedExampleViewController: UIViewController {

    private let balanceLabel = RollingNumberLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
    }

    private func setupLabel() {
        balanceLabel.animationDuration = 0.5 // 애니메이션 속도 조절
        balanceLabel.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)

        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(balanceLabel)

        NSLayoutConstraint.activate([
            balanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            balanceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            balanceLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    /// 잔액 업데이트 예제
    func updateBalance(from oldBalance: Int, to newBalance: Int) {
        // 이전 값 설정 (첫 호출시)
        if balanceLabel.attributedText == nil {
            balanceLabel.setAttributedText(createBalanceString(oldBalance), animated: false)
        }

        // 새 값으로 애니메이션
        balanceLabel.setAttributedText(createBalanceString(newBalance), animated: true)
    }

    private func createBalanceString(_ balance: Int) -> NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        formatter.currencyCode = "KRW"

        let balanceString = formatter.string(from: NSNumber(value: balance)) ?? "₩\(balance)"

        let attributed = NSMutableAttributedString(string: balanceString)

        // 전체 스타일
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 36, weight: .heavy),
            .foregroundColor: UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        ], range: NSRange(location: 0, length: balanceString.count))

        return attributed
    }
}
