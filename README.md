
# 🌀 Curve Slider

A customizable and interactive curved slider widget for Flutter, designed with a smooth arc UI, tick marks, and thumb image support. Great for selecting values like currency, volume, or progress with a unique look.

## 🚀 Features

- 🎯 Adjustable `min`, `max`, and `initialValue`
- 🧮 Curved slider path using quadratic Bézier
- 🖼️ Custom thumb image
- 🔊 Optional tick sound on change
- 🎨 Fully themeable and responsive
- 🔄 `onChanged` callback to return slider value on drag/text input

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  curve_slider: ^0.0.3
```

## 💡 Example

Here's a minimal example of how to use the `CurveSlider` widget:

```dart
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

