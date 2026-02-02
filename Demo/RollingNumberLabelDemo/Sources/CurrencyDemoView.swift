//
//  CurrencyDemoView.swift
//  RollingNumberLabelDemo
//
//  Created on 2026-02-02.
//

import SwiftUI
import RollingNumberLabel

struct CurrencyDemoView: View {
    @State private var balance: Int = 1_000_000

    private var attributedBalance: NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let numberString = formatter.string(from: NSNumber(value: balance)) ?? "\(balance)"
        let fullString = "\(numberString)원"

        let attributed = NSMutableAttributedString(string: fullString)

        // Number style
        let numberRange = NSRange(location: 0, length: numberString.count)
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 36, weight: .heavy),
            .foregroundColor: UIColor.systemGreen
        ], range: numberRange)

        // "원" suffix style
        let suffixRange = NSRange(location: numberString.count, length: 1)
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 24, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ], range: suffixRange)

        return attributed
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 8) {
                Text("잔액")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                RollingNumberLabelView(
                    attributedText: attributedBalance,
                    animationDuration: 0.4,
                    textAlignment: .center
                )
                .accessibilityIdentifier("currencyLabel")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 16) {
                Text("금액 변경")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach([-100_000, -10_000, 10_000, 100_000], id: \.self) { amount in
                        Button {
                            balance = max(0, balance + amount)
                        } label: {
                            Text(formatAmount(amount))
                                .font(.callout)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("amount_\(amount)")
                    }
                }

                HStack(spacing: 20) {
                    Button("999,999원") {
                        balance = 999_999
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("set999999")

                    Button("1,000,000원") {
                        balance = 1_000_000
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("set1000000")

                    Button("10,000,000원") {
                        balance = 10_000_000
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("set10000000")
                }
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Currency Demo")
    }

    private func formatAmount(_ amount: Int) -> String {
        let prefix = amount >= 0 ? "+" : ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(prefix)\(formatter.string(from: NSNumber(value: amount)) ?? "\(amount)")"
    }
}

#Preview {
    NavigationView {
        CurrencyDemoView()
    }
}
