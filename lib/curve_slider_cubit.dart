part of 'curve_slider_view.dart';

class CurveSliderCubit extends Cubit<CurvedSliderState> {
  final List<AudioPlayer> _playerPool = [];
  int _poolIndex = 0;
  int _lastPlayedTick = -1;
  DateTime? _lastTickTime;
  final String? tickSound;
  final ValueChanged<double>? onChanged;

  CurveSliderCubit(super.initialState, {this.tickSound,this.onChanged}) {
    _initAudio();
  }

  Future<void> _initAudio() async {
    if (tickSound == null) return;
    for (int i = 0; i < 6; i++) {
      final player = AudioPlayer();
      await player.setSourceAsset(tickSound!);
      await player.setReleaseMode(ReleaseMode.stop);
      _playerPool.add(player);
    }
  }

  void updateFromText(String input) {
    final parsed = double.tryParse(input);
    if (parsed != null) {
      final clamped = parsed.clamp(state.min, state.max);
      emit(state.copyWith(sliderValue: clamped));
      onChanged?.call(clamped);
    }
  }

  void updateSliderByTouch(Offset local, Size size) {
    final cx = size.width / 2;
    final by = size.height * 0.9;
    final aw = size.width * 0.8;
    final startX = cx - aw / 2;
    final endX = cx + aw / 2;
    final ctrl = Offset(cx, by - state.curvature);

    double bestT = 0;
    double bestD = double.infinity;

    for (var i = 0; i <= 100; i++) {
      final t = i / 100;
      final pos = _quadraticBezier(startX, by, ctrl, endX, by, t);
      final d = (pos - local).distance;
      if (d < bestD) {
        bestD = d;
        bestT = t;
      }
    }

    final newValue = state.min + (state.max - state.min) * bestT;
    final currentTick = ((bestT * state.totalTicks).round()).clamp(0, state.totalTicks);
    if (currentTick != _lastPlayedTick) {
      _lastPlayedTick = currentTick;
      _playTickSound();
    }

    if ((state.sliderValue - newValue).abs() > 0.00001) {
      final controller = state.textEditingController;
      controller.text = newValue.toStringAsFixed(6);
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      emit(state.copyWith(sliderValue: newValue));
      onChanged?.call(newValue);
    }
  }

  void _playTickSound() {
    if (_playerPool.isEmpty) return;
    final now = DateTime.now();
    if (_lastTickTime == null || now.difference(_lastTickTime!) > const Duration(milliseconds: 30)) {
      _lastTickTime = now;
      HapticFeedback.selectionClick();
      final player = _playerPool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _playerPool.length;
      player.stop().then((_) {
        player.seek(Duration.zero);
        player.resume();
      });
    }
  }

  Offset _quadraticBezier(double x0, double y0, Offset control, double x2, double y2, double t) {
    final x = pow(1 - t, 2) * x0 + 2 * (1 - t) * t * control.dx + pow(t, 2) * x2;
    final y = pow(1 - t, 2) * y0 + 2 * (1 - t) * t * control.dy + pow(t, 2) * y2;
    return Offset(x.toDouble(), y.toDouble());
  }
}
