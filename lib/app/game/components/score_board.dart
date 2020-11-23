import 'package:flutter/material.dart';

import '../ludo.dart';

class ScoreBoard {
  final Ludo game;

  Color playerColor;
  String playerName;
  int lastNumber;

  Rect _rect;
  Paint _fillPaint;
  Paint _strokePaint;

  Size _screenSize;
  double _scoreSize;
  double _fontSize;
  double _horizontalCenter;


  int score;

  ScoreBoard(this.game) {
    _fillPaint = Paint();
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;

  }

  void render(Canvas c) {
    _fillPaint.color = Colors.white;

    _rect = Rect.fromLTRB(
      _horizontalCenter - 4 * _scoreSize,
      _scoreSize * 0.2,
      _horizontalCenter + 4 * _scoreSize,
      _scoreSize * 0.8,
    );

    RRect border = RRect.fromRectAndRadius(_rect, Radius.circular(20));
    c.drawRRect(border, _fillPaint);
    c.drawRRect(border, _strokePaint);

    _fillPaint.color = Colors.black;
    TextPainter painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    painter.text = TextSpan(
      text: '$playerName',
      style: TextStyle(
        color: Colors.black,
        fontSize: _fontSize,
      ),
    );

    painter.layout();

    Offset position = Offset(
      _rect.center.dx - painter.width / 2,
      _rect.center.dy - painter.height / 2,
    );

    painter.paint(c, position);

    _rect = Rect.fromLTRB(
      _horizontalCenter - 3.95 * _scoreSize,
      _scoreSize * 0.25,
      _horizontalCenter - 2 * _scoreSize,
      _scoreSize * 0.75,
    );

    _fillPaint.color = playerColor;

    border = RRect.fromRectAndRadius(_rect, Radius.circular(20));
    c.drawRRect(border, _fillPaint);
    c.drawRRect(border, _strokePaint);

    _rect = Rect.fromLTRB(
      _horizontalCenter + 2 * _scoreSize,
      _scoreSize * 0.25,
      _horizontalCenter + 3.95 * _scoreSize,
      _scoreSize * 0.75,
    );

    painter.text = TextSpan(
      text: 'Ultimo valor: $lastNumber',
      style: TextStyle(
        color: Colors.black,
        fontSize: .6 * _fontSize,
      ),
    );

    painter.layout();

    position = Offset(
      _rect.center.dx - 0.6 * painter.width,
      _rect.center.dy - painter.height / 2,
    );

    painter.paint(c, position);
  }

  void resize() {
    _screenSize = game.screenSize;

    if (_screenSize.aspectRatio > 1) {
      _scoreSize = _screenSize.height * 0.08;
      _fontSize = _screenSize.height * 0.03;
    } else {
      _scoreSize = _screenSize.width * 0.1;
      _fontSize = _screenSize.width * 0.04;
    }

    _horizontalCenter = _screenSize.width / 2;
  }

  void onTapDown() {}

  void update(double t) {
  }

  bool checkClick(Offset position) => _rect.contains(position);

  void setInfo({
    Color playerColor,
    String playerName,
    int lastNumber,
    int score,
  }) {
    this.playerColor = playerColor;
    this.playerName = playerName;
    this.lastNumber = lastNumber;
    this.score = score;
  }
}
