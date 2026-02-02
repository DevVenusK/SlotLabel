//
//  MultilineDemoView.swift
//  RollingNumberLabelDemo
//
//  Created on 2026-02-02.
//

import SwiftUI
import RollingNumberLabel

struct MultilineDemoView: View {
    @State private var stats = DashboardStats()
    @State private var isAutoUpdating = false
    @State private var timer: Timer?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Dashboard Cards
                dashboardSection

                Divider()
                    .padding(.horizontal)

                // Crypto Prices
                cryptoSection

                Divider()
                    .padding(.horizontal)

                // Controls
                controlsSection
            }
            .padding(.vertical)
        }
        .navigationTitle("Multiline Demo")
        .onDisappear {
            stopAutoUpdate()
        }
    }

    // MARK: - Dashboard Section

    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dashboard Stats")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Users",
                    value: stats.users,
                    suffix: "",
                    color: .blue
                )
                .accessibilityIdentifier("usersCard")

                StatCard(
                    title: "Revenue",
                    value: stats.revenue,
                    suffix: "원",
                    color: .green
                )
                .accessibilityIdentifier("revenueCard")

                StatCard(
                    title: "Orders",
                    value: stats.orders,
                    suffix: "",
                    color: .orange
                )
                .accessibilityIdentifier("ordersCard")

                StatCard(
                    title: "Views",
                    value: stats.views,
                    suffix: "",
                    color: .purple
                )
                .accessibilityIdentifier("viewsCard")
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Crypto Section

    private var cryptoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Crypto Prices")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 12) {
                CryptoRow(
                    symbol: "BTC",
                    name: "Bitcoin",
                    price: stats.btcPrice,
                    color: .orange
                )
                .accessibilityIdentifier("btcRow")

                CryptoRow(
                    symbol: "ETH",
                    name: "Ethereum",
                    price: stats.ethPrice,
                    color: .purple
                )
                .accessibilityIdentifier("ethRow")

                CryptoRow(
                    symbol: "SOL",
                    name: "Solana",
                    price: stats.solPrice,
                    color: .cyan
                )
                .accessibilityIdentifier("solRow")
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Controls Section

    private var controlsSection: some View {
        VStack(spacing: 16) {
            Text("Controls")
                .font(.headline)

            HStack(spacing: 16) {
                Button("Update All") {
                    updateAllStats()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("updateAllButton")

                Button("Reset") {
                    resetStats()
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("resetButton")
            }

            Toggle("Auto Update", isOn: $isAutoUpdating)
                .padding(.horizontal, 40)
                .onChange(of: isAutoUpdating) { _, newValue in
                    if newValue {
                        startAutoUpdate()
                    } else {
                        stopAutoUpdate()
                    }
                }
                .accessibilityIdentifier("autoUpdateToggle")

            Text("Toggle auto-update to see continuous rolling animations")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Actions

    private func updateAllStats() {
        stats.users += Int.random(in: 1...50)
        stats.revenue += Int.random(in: 10000...100000)
        stats.orders += Int.random(in: 1...20)
        stats.views += Int.random(in: 100...1000)

        stats.btcPrice += Int.random(in: -500000...500000)
        stats.ethPrice += Int.random(in: -50000...50000)
        stats.solPrice += Int.random(in: -5000...5000)

        // Keep prices positive
        stats.btcPrice = max(50000000, stats.btcPrice)
        stats.ethPrice = max(2000000, stats.ethPrice)
        stats.solPrice = max(100000, stats.solPrice)
    }

    private func resetStats() {
        stats = DashboardStats()
    }

    private func startAutoUpdate() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            updateAllStats()
        }
    }

    private func stopAutoUpdate() {
        timer?.invalidate()
        timer = nil
        isAutoUpdating = false
    }
}

// MARK: - Data Model

private struct DashboardStats {
    var users: Int = 12_345
    var revenue: Int = 98_765_432
    var orders: Int = 5_678
    var views: Int = 234_567

    var btcPrice: Int = 145_234_000
    var ethPrice: Int = 5_432_000
    var solPrice: Int = 234_500
}

// MARK: - Stat Card Component

private struct StatCard: View {
    let title: String
    let value: Int
    let suffix: String
    let color: Color

    private var formattedValue: NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let numberString = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        let fullString = suffix.isEmpty ? numberString : "\(numberString)\(suffix)"

        let attributed = NSMutableAttributedString(string: fullString)

        let numberRange = NSRange(location: 0, length: numberString.count)
        attributed.addAttributes([
            .font: UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor(color)
        ], range: numberRange)

        if !suffix.isEmpty {
            let suffixRange = NSRange(location: numberString.count, length: suffix.count)
            attributed.addAttributes([
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ], range: suffixRange)
        }

        return attributed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            RollingNumberLabelView(
                attributedText: formattedValue,
                animationDuration: 0.35,
                textAlignment: .left
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Crypto Row Component

private struct CryptoRow: View {
    let symbol: String
    let name: String
    let price: Int
    let color: Color

    private var formattedPrice: NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let numberString = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        let fullString = "₩\(numberString)"

        let attributed = NSMutableAttributedString(string: fullString)

        // Currency symbol
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ], range: NSRange(location: 0, length: 1))

        // Number
        attributed.addAttributes([
            .font: UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: UIColor.label
        ], range: NSRange(location: 1, length: numberString.count))

        return attributed
    }

    var body: some View {
        HStack {
            // Crypto Icon
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(symbol)
                        .font(.caption.bold())
                        .foregroundStyle(color)
                }

            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(symbol)
                    .font(.headline)
                Text(name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Price
            RollingNumberLabelView(
                attributedText: formattedPrice,
                animationDuration: 0.3,
                textAlignment: .right
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationView {
        MultilineDemoView()
    }
}
