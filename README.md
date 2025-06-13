
# 🌀 Curve Slider

A customizable and interactive curved slider widget for Flutter, designed with a smooth arc UI, tick marks, and thumb image support. Great for selecting values like currency, volume, or progress with a unique look.

## 🚀 Features

- 🎯 Adjustable `min`, `max`, `initialValue`, and `totalTicks`
- 🧮 Curved path using quadratic Bézier curves
- 🖼️ Support for custom thumb image
- 🔊 Tick sound on value change (optional)
- 🌈 Fully themeable & responsive layout
- 📉 Optional text field for value input
- 🔄 Real-time `onChanged` callback
- 🤏 Haptic feedback support (via `HapticFeedback.selectionClick()`)

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  curve_slider: ^0.0.4
```

## 💡 Example

Here's a minimal example of how to use the `CurveSlider` widget:

```dart@
CurveSliderView(
          initialValue: 0.002,
          min: 0.001,
          max: 0.005,
          curvature: 120,
          totalTicks: 40,
          thumbImage: 'assets/images/fingerprint.png',
          tickSound: 'sounds/tick.mp3',
          onChanged: (value) {
            debugPrint("on change: $value");
          },
        )
```

## 🛠 Maintainers

Built and maintained by [Harshit Rajput](https://github.com/Harshit2027)
