import 'package:flutter/material.dart';

import '../ludo.dart';

class ExitButton {
  final Ludo game;

  Rect _rect;

  Paint _fillPaint;
  Paint _strokePaint;

  Size _screenSize;

  double _boxSize;
  double _fontSize;

  double _horizontalCenter;

  ExitButton(this.game) {
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
      _horizontalCenter - 6 * _boxSize,
      _screenSize.height - 1.9 * _boxSize,
      _horizontalCenter - 4 * _boxSize,
      _screenSize.height - _boxSize,
    );

    final border = RRect.fromRectAndRadius(_rect, Radius.circular(10));
    c.drawRRect(border, _fillPaint);
    c.drawRRect(border, _strokePaint);

    _fillPaint.color = Colors.black;
    final painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    painter.text = TextSpan(
      text: 'Sair',
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
      _boxSize = _screenSize.height * 0.06;
      _fontSize = _screenSize.height * 0.03;
    } else {
      _boxSize = _screenSize.width * 0.06;
      _fontSize = _screenSize.width * 0.03;
    }

    _horizontalCenter = _screenSize.width / 2;
  }

  bool checkClick(Offset position) => _rect.contains(position);
}
