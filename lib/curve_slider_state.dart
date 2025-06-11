part of 'curve_slider_view.dart';

class CurvedSliderState extends Equatable {
  final double sliderValue;
  final TextEditingController textEditingController;
  final double min;
  final double max;
  final double curvature;
  final int totalTicks;
  final double availableBalance;
  final String currencyUnit;

  const CurvedSliderState({
    this.sliderValue = 0,
    required this.textEditingController,
    this.min = 0.0,
    this.max = 0.005,
    this.curvature = 100,
    this.totalTicks = 30,
    this.availableBalance=0.000927,
    this.currencyUnit="BTC"
  });

  @override
  List<Object?> get props => [sliderValue, min, max, curvature, totalTicks, availableBalance, currencyUnit];

  CurvedSliderState copyWith({
    double? sliderValue,
    TextEditingController? textEditingController,
    double? min,
    double? max,
    double? curvature,
    int? totalTicks,
    double? availableBalance,
    String? currencyUnit,
  }) {
    return CurvedSliderState(
      sliderValue: sliderValue ?? this.sliderValue,
      textEditingController: textEditingController ?? this.textEditingController,
      min: min ?? this.min,
      max: max ?? this.max,
      curvature: curvature ?? this.curvature,
      totalTicks: totalTicks ?? this.totalTicks,
      availableBalance: availableBalance ?? this.availableBalance,
      currencyUnit: currencyUnit ?? this.currencyUnit,
    );
  }
}
