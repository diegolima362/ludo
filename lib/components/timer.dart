
import 'package:flutter/material.dart';
import 'package:ludo/util/util.dart';

import '../ludo.dart';

class Timer {
  final Ludo game;

  int remainingTime;

  Rect _rect;
  Paint _fillPaint;
  Paint _strokePaint;

  Size _screenSize;
  double _timerSize;
  double _fontSize;
  double _verticalCenter;
  double _horizontalCenter;

  double _counter;

  int _timeLimit;

  int lastPlayTime;

  Timer(this.game) {
    _fillPaint = Paint();
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;

    _counter = 0;
    _timeLimit = game.limitTime;
    remainingTime = _timeLimit;
  }

  void reset() {
    lastPlayTime = _counter.toInt();
    _counter = 0;
    remainingTime = _timeLimit;
  }

  void render(Canvas c) {
    _fillPaint.color = remainingTime < 4 ? AppColors.rollDice : Colors.white;

    _rect = Rect.fromLTRB(
      _horizontalCenter + 5 * _timerSize,
      _screenSize.height - 3 * _timerSize,
      _horizontalCenter + 6 * _timerSize,
      _screenSize.height - 2 * _timerSize,
    );

    final timerBorder = RRect.fromRectAndRadius(_rect, Radius.circular(20));
    c.drawRRect(timerBorder, _fillPaint);
    c.drawRRect(timerBorder, _strokePaint);

    _fillPaint.color = Colors.black;
    final painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    painter.text = TextSpan(
      text: '$remainingTime',
      style: TextStyle(
        color: Colors.black,
        fontSize: _fontSize,
      ),
    );

    painter.layout();

    final position = Offset(
      _rect.center.dx - painter.width / 2,
      _rect.center.dy - painter.height / 2,
    );

    painter.paint(c, position);
  }

  void resize() {
    _screenSize = game.screenSize;

    if (_screenSize.aspectRatio > 1) {
      _timerSize = _screenSize.height * 0.06;
      _fontSize = _screenSize.height * 0.04;
    } else {
      _timerSize = _screenSize.width * 0.06;
      _fontSize = _screenSize.width * 0.04;
    }

    _horizontalCenter = _screenSize.width / 2;
    _verticalCenter = _screenSize.height / 2;
  }

  void onTapDown() {}

  void update(double t) {
    _counter += t;

    if (_counter >= _timeLimit + 1) {
      _counter -= _timeLimit;
    }

    remainingTime = _timeLimit - _counter.toInt();
  }

  bool checkClick(Offset position) => _rect.contains(position);
}
