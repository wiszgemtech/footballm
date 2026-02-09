import 'dart:async';
import 'package:footballmanager/core/models/match_state.dart';

class MatchTimer {
  final MatchState match;
  final Duration totalDuration;
  late Timer _timer;
  int _elapsedSeconds = 0;

  MatchTimer({
    required this.match,
    this.totalDuration = const Duration(seconds: 30),
  });

  void start(void Function() onTick, void Function() onFinish) {
    final interval = totalDuration.inMilliseconds ~/ 90; // ms per minute
    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      _elapsedSeconds++;
      match.minute++;
      onTick();

      if (match.minute >= 90) {
        _timer.cancel();
        onFinish();
      }
    });
  }

  void stop() {
    _timer.cancel();
  }
}
