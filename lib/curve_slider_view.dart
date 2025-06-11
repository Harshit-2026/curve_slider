import 'dart:math';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ByteData;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'arc_slider/arc_slider.dart';

part 'curve_slider_state.dart';
part 'curve_slider_cubit.dart';

class CurveSliderView extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final double curvature;
  final int totalTicks;
  final String? thumbImage;
  final String? tickSound;
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

                  const SizedBox(height: 48),
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