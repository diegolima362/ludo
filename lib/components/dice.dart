import 'dart:math';

import 'package:flutter/material.dart';

import '../ludo.dart';
import '../util/util.dart';

class Dice {
  final Ludo game;

  int number;
  int diceMaxValue;

  bool canRoll;

  Random _rand;

  Rect _rect;
  Paint _fillPaint;
  Paint _strokePaint;

  Size _screenSize;
  double _diceSize;
  double _fontSize;
  double _verticalCenter;
  double _horizontalCenter;

  double _counter;

  Dice(this.game) {
    _fillPaint = Paint();
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;

    _rand = Random();
    _counter = 0;

    number = 0;
    diceMaxValue = 10;
    canRoll = false;
  }

  void render(Canvas c) {
    _fillPaint.color = Colors.white;
    if (canRoll) {
      _fillPaint.color =
          _counter.toInt() == 1 ? AppColors.rollDice : Colors.white;
    }

    _rect = Rect.fromLTRB(
      _horizontalCenter - (_diceSize / 2),
      _screenSize.height - (1.2 * _diceSize),
      _horizontalCenter + (_diceSize / 2),
      _screenSize.height - (0.2 * _diceSize),
    );

    final diceBorder = RRect.fromRectAndRadius(_rect, Radius.circular(20));
    c.drawRRect(diceBorder, _fillPaint);
    c.drawRRect(diceBorder, _strokePaint);

    _fillPaint.color = Colors.black;
    final painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    painter.text = TextSpan(
      text: canRoll ? 'Jogar\nDado' : '$number',
      style: TextStyle(
        color: Colors.black,
        fontSize: canRoll ? 0.4 * _fontSize : _fontSize,
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
      _diceSize = _screenSize.height * 0.125;
      _fontSize = _screenSize.height * 0.1;
    } else {
      _diceSize = _screenSize.width * 0.125;
      _fontSize = _screenSize.width * 0.1;
    }

    _horizontalCenter = _screenSize.width / 2;
    _verticalCenter = _screenSize.height / 2;
  }

  void onTapDown() {}

  void update(double t) {
    _counter += t;

    if (_counter >= 2) {
      _counter -= 2;
    }
  }

  void roll() {
    number = _rand.nextInt(diceMaxValue);
    print('> dice value: $number');
  }

  bool checkClick(Offset position) => _rect.contains(position);
}
