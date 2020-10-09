import 'package:flutter/material.dart';

import '../ludo.dart';

class StartButton {
  final Ludo game;

  Rect _rect;

  Paint _fillPaint;
  Paint _strokePaint;

  Size _screenSize;

  double _boxSize;
  double _fontSize;

  double _horizontalCenter;

  StartButton(this.game) {
    _fillPaint = Paint();
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;

    resize();
  }

  void render(Canvas c) {
    _fillPaint.color = Colors.white;

    _rect = Rect.fromLTRB(
      _horizontalCenter - _boxSize,
      _screenSize.height - (1.2 * _boxSize),
      _horizontalCenter + _boxSize,
      _screenSize.height - (0.2 * _boxSize),
    );

    final border = RRect.fromRectAndRadius(_rect, Radius.circular(20));
    c.drawRRect(border, _fillPaint);
    c.drawRRect(border, _strokePaint);

    _fillPaint.color = Colors.black;
    final painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    painter.text = TextSpan(
      text: 'Start',
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
      _boxSize = _screenSize.height * 0.125;
      _fontSize = _screenSize.height * 0.1;
    } else {
      _boxSize = _screenSize.width * 0.125;
      _fontSize = _screenSize.width * 0.1;
    }

    _horizontalCenter = _screenSize.width / 2;
  }

  bool checkClick(Offset position) => _rect.contains(position);
}
