import 'package:flutter/material.dart';

import '../ludo.dart';

class Token {
  final int id;
  final int homeId;

  final Ludo game;

  Rect rect;
  Color playerColor;

  Paint _fillPaint;
  Paint _strokePaint;

  Offset currentSpot;
  final Offset spawn;

  Size _screenSize;

  double _playerSize;

  Token({
    @required this.game,
    @required this.id,
    @required this.homeId,
    @required this.spawn,
    @required this.playerColor,
  }) {
    currentSpot = spawn;
    _fillPaint = Paint();
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;
  }

  void render(Canvas c) {
    _fillPaint.color = playerColor;

    double _playerInnerSize = _playerSize / 2.5;

    c.drawCircle(currentSpot, _playerSize, _fillPaint);
    c.drawCircle(currentSpot, _playerSize, _strokePaint);

    _fillPaint.color = Colors.white;
    c.drawCircle(currentSpot, _playerInnerSize, _fillPaint);
    c.drawCircle(currentSpot, _playerInnerSize, _strokePaint);

    // _fillPaint.color = Colors.pink;

    rect = Rect.fromLTRB(
      currentSpot.dx - _playerSize,
      currentSpot.dy - _playerSize,
      currentSpot.dx + _playerSize,
      currentSpot.dy + _playerSize,
    );

    // c.drawRect(rect, _fillPaint);
  }

  bool get isInBase => currentSpot == spawn;

  void moveTo(Offset destination) {
    print('hey');

    currentSpot = destination;
  }

  void update(double t) {}

  void resize() {
    _screenSize = game.screenSize;

    if (_screenSize.aspectRatio > 1) {
      _playerSize = _screenSize.height * 0.01;
    } else {
      _playerSize = _screenSize.width * 0.01;
    }
  }

  void onTapDown() {}

  String toString() => "${this.playerColor.value}, ${this.currentSpot}";
}
