import 'dart:math';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ByteData;
import 'package:flutter_bloc/flutter_bloc.dart';

part 'curve_slider_state.dart';
part 'curve_slider_cubit.dart';

class CurveSliderView extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final double curvature;
  final double availableBalance;
  final int totalTicks;
  final String? thumbImage;
  final String? tickSound;
  final String currencyUnit;
  final ValueChanged<double>? onChanged;

  const CurveSliderView({
    super.key,
    this.initialValue = 0.0,
    this.min = 0.0,
    this.max = 0.005,
    this.curvature = 100,
    this.totalTicks = 30,
    this.thumbImage="assets/images/fingerprint.png",
    this.tickSound='sounds/tick.mp3',
    this.availableBalance=0.000927,
    this.currencyUnit="BTC",
    this.onChanged,
  });

  @override
  State<CurveSliderView> createState() => _CurveSliderViewState();
}

class _CurveSliderViewState extends State<CurveSliderView> {
  final GlobalKey _paintKey = GlobalKey();
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    if (widget.thumbImage != null) {
      loadUiImage(widget.thumbImage!).then((value) {
        setState(() => _image = value);
      });
    }
  }

  Future<ui.Image> loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider<CurveSliderCubit>(
      create: (context) => CurveSliderCubit(
        CurvedSliderState(
          sliderValue: widget.initialValue.clamp(widget.min, widget.max),
          textEditingController: TextEditingController(text: widget.initialValue.toStringAsFixed(6)),
          min: widget.min,
          max: widget.max,
          curvature: widget.curvature,
          totalTicks: widget.totalTicks,
          availableBalance: widget.availableBalance,
          currencyUnit: widget.currencyUnit,
        ),
        tickSound: widget.tickSound,
        onChanged: widget.onChanged,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1D1F33),
        body: Center(
          child: BlocBuilder<CurveSliderCubit, CurvedSliderState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: state.textEditingController,
                    onChanged: (text) => context.read<CurveSliderCubit>().updateFromText(text),
                    onTapOutside: (_) => FocusScope.of(context).requestFocus(FocusNode()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}'))],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: 'Available ',
                      style: TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: '${widget.availableBalance.toStringAsFixed(6)} ${widget.currencyUnit}',
                          style: TextStyle(color: Colors.cyanAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (details) {
                          final box = _paintKey.currentContext!.findRenderObject() as RenderBox;
                          final local = box.globalToLocal(details.globalPosition);
                          context.read<CurveSliderCubit>().updateSliderByTouch(local, box.size);
                        },
                        child: CustomPaint(
                          key: _paintKey,
                          size: Size(MediaQuery.of(context).size.width, 200),
                          painter: ArcSliderPainter(
                            value: state.sliderValue,
                            min: state.min,
                            max: state.max,
                            curvature: state.curvature,
                            image: _image,
                          ),
                          child: SizedBox(width: MediaQuery.of(context).size.width, height: 200),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


class ArcSliderPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final double curvature;
  final ui.Image? image;

  ArcSliderPainter({required this.value, required this.min, required this.max, required this.curvature, this.image});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.9;
    final arcWidth = size.width * 0.8;

    final startX = centerX - arcWidth / 2;
    final endX = centerX + arcWidth / 2;
    final controlPoint = Offset(centerX, baseY - curvature);

    final path = Path()
      ..moveTo(startX, baseY)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endX, baseY);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.grey.shade800;

    final tickPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 1;

    canvas.drawPath(path, trackPaint);

    // Draw ticks
    const tickCount = 30;
    for (int i = 0; i <= tickCount; i++) {
      double t = i / tickCount;
      final pos = _quadraticBezier(startX, baseY, controlPoint, endX, baseY, t);
      final tickEnd = Offset(pos.dx, pos.dy + (i % 5 == 0 ? 12 : 6));
      canvas.drawLine(pos, tickEnd, tickPaint);
    }

    // ✅ Draw min and max text
    final textStyle = TextStyle(color: Colors.white, fontSize: 14);
    final textPainterMin = TextPainter(
      text: TextSpan(text: min.toStringAsFixed(2), style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPainterMax = TextPainter(
      text: TextSpan(text: max.toStringAsFixed(6), style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final minOffset = Offset(startX - textPainterMin.width / 2, baseY + 26);
    final maxOffset = Offset(endX - textPainterMax.width / 2, baseY + 26);

    textPainterMin.paint(canvas, minOffset);
    textPainterMax.paint(canvas, maxOffset);

    // Thumb
    double t = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final thumbOffset = _quadraticBezier(startX, baseY, controlPoint, endX, baseY, t);

    // Draw image if provided
    if (image != null) {
      const double imageSize = 50;
      final imageOffset = Offset(thumbOffset.dx - imageSize * 0.5, thumbOffset.dy - imageSize * 0.5);
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(imageOffset.dx, imageOffset.dy, imageSize, imageSize),
        Paint(),
      );
    }
  }

  Offset _quadraticBezier(double x0, double y0, Offset control, double x2, double y2, double t) {
    final x = pow(1 - t, 2) * x0 + 2 * (1 - t) * t * control.dx + pow(t, 2) * x2;
    final y = pow(1 - t, 2) * y0 + 2 * (1 - t) * t * control.dy + pow(t, 2) * y2;
    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
