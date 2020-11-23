import 'dart:ui';

import 'package:flutter/material.dart';

import '../ludo.dart';

class WinnerDisplay {
  final Ludo game;
  Rect _rect;

  Paint _fillPaint;
  Paint _strokePaint;

  Size _screenSize;

  double _boxSize;
  double _fontSize;

  double _horizontalCenter;
  double _verticalCenter;

  WinnerDisplay(this.game) {
    _fillPaint = Paint();
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;
    resize();
  }

  void render(Canvas c) {
    _fillPaint.color = game.winner?.playerColor;

    _rect = Rect.fromLTRB(
      _horizontalCenter - _boxSize,
      _verticalCenter - _boxSize,
      _horizontalCenter + _boxSize,
      _verticalCenter + _boxSize,
    );

    RRect border = RRect.fromRectAndRadius(_rect, Radius.circular(20));
    c.drawRRect(border, _fillPaint);
    c.drawRRect(border, _strokePaint);

    _fillPaint.color = Colors.white;

    _rect = Rect.fromLTRB(
      _horizontalCenter - _boxSize * .8,
      _verticalCenter - _boxSize * .8,
      _horizontalCenter + _boxSize * .8,
      _verticalCenter + _boxSize * .8,
    );

    border = RRect.fromRectAndRadius(_rect, Radius.circular(20));
    c.drawRRect(border, _fillPaint);
    c.drawRRect(border, _strokePaint);

    _fillPaint.color = Colors.black;
    TextPainter painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    painter.text = TextSpan(
      text: 'Vencedor: ${game.winner.name}\n',
      style: TextStyle(
        color: Colors.black,
        fontSize: _fontSize,
      ),
    );

    painter.layout();

    Offset position = Offset(
      _rect.center.dx - painter.width / 2,
      _rect.center.dy - painter.height * 1.7,
    );

    painter.paint(c, position);

    if (game.winner.isHuman) {
      painter.text = TextSpan(
        text: 'Pontos: ${game.winner.score}\n'
            'Jogadas: ${game.winner.plays}\n'
            'Ataques: ${game.winner.enemiesHit}\n',
        style: TextStyle(
          color: Colors.black,
          fontSize: _fontSize * 0.8,
        ),
      );

      painter.layout();

      position = Offset(
        _rect.center.dx - painter.width / 2,
        _rect.center.dy - painter.height / 2,
      );

      painter.paint(c, position);
    }
  }

  void resize() {
    _screenSize = game.screenSize;

    if (_screenSize.aspectRatio > 1) {
      _boxSize = _screenSize.height * 0.3;
      _fontSize = _screenSize.height * 0.05;
    } else {
      _boxSize = _screenSize.width * 0.3;
      _fontSize = _screenSize.width * 0.05;
    }

    _horizontalCenter = _screenSize.width / 2;
    _verticalCenter = _screenSize.height / 2;
  }

  void update(double t) {}
}
