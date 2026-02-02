# RollingNumberLabel

A UIView that animates number changes with a rolling (slot machine) effect. Only changed digits roll upward while unchanged characters remain static.

## Features

- Rolling animation for digit changes (slot machine effect)
- Supports `NSAttributedString` with preserved attributes per character
- Automatic digit alignment from right-to-left (ideal for currency)
- Smooth enter/exit animations when digit count changes
- Self-sizing support (Auto Layout compatible)
- Text alignment options (left, center, right)
- Animation queue for rapid updates

## Requirements

- iOS 15.0+
- Swift 5.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/DevVenusK/SlotLabel.git", from: "1.0.0")
]
```

Or in Xcode:
1. File > Add Package Dependencies...
2. Enter the repository URL: `https://github.com/DevVenusK/SlotLabel.git`
3. Select version and add to your project

## Usage

### Basic Usage

```swift
import RollingNumberLabel

class ViewController: UIViewController {

    private let priceLabel = RollingNumberLabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup with Auto Layout
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            priceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Set initial value (no animation)
        let initialText = createPriceString(1_000_000)
        priceLabel.setAttributedText(initialText, animated: false)
    }

    func updatePrice(_ newPrice: Int) {
        let newText = createPriceString(newPrice)
        // Animate the change
        priceLabel.setAttributedText(newText, animated: true)
    }

    private func createPriceString(_ price: Int) -> NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let priceString = formatter.string(from: NSNumber(value: price)) ?? "\(price)"

        return NSAttributedString(
            string: "\(priceString)원",
            attributes: [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.black
            ]
        )
    }
}
```

### Customization

```swift
let label = RollingNumberLabel()

// Animation duration (default: 0.3)
label.animationDuration = 0.5

// Animation timing function
label.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)

// Text alignment (default: .left)
label.textAlignment = .center
```

### UILabel Extension

You can also use the UILabel extension to add rolling animation to existing labels:

```swift
import RollingNumberLabel

let label = UILabel()
label.setAttributedTextWithRolling(attributedText, animated: true, duration: 0.3)
```

## Animation Behavior

### Same digit count
```
1,000,000원 → 1,232,987원

- Unchanged: 1, commas, 원
- Rolling: 0→2, 0→3, 0→2, 0→9, 0→8, 0→7
```

### Digit count increase
```
999,999원 → 1,000,000원

- New characters fade in from below
- Existing digits roll to new values
- Suffix (원) slides to new position
```

### Digit count decrease
```
1,000,000원 → 999,999원

- Removed characters fade out upward
- Existing digits roll to new values
- Suffix (원) slides to new position
```

## Demo App

The repository includes a demo app to showcase all features.

### Running the Demo

Using [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
cd Demo
xcodegen generate
open RollingNumberLabelDemo.xcodeproj
```

Or create a new Xcode project manually and add the package dependency.

### Demo Screens

- **Basic Demo**: Simple number increment/decrement
- **Currency Demo**: Korean Won formatting with digit count changes
- **Customization Demo**: Adjust animation duration, alignment, font size, colors
- **Stress Test**: Rapid update performance testing

## Testing

### Unit Tests (Swift Testing)

```bash
swift test
```

### UI Tests

Run UI tests through Xcode after generating the demo project.

## License

MIT License
