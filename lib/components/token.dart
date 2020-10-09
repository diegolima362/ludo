import 'package:flutter/material.dart';

import '../ludo.dart';

class Token {
  final int id;
  final int homeId;

  bool atCenter;

  final Ludo game;

  Rect rect;
  Color playerColor;

  Paint _fillPaint;
  Paint _strokePaint;

  Offset currentSpot;
  Offset spawn;

  Size _screenSize;

  double _playerSize;

  int _currentStep;

  List<Offset> path;

  Token({
    @required this.game,
    @required this.id,
    @required this.homeId,
    @required this.spawn,
    @required this.playerColor,
    @required this.path,
  }) {
    _currentStep = 0;
    atCenter = false;
    currentSpot = spawn;
    _fillPaint = Paint();
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;

    resize();
  }

  void render(Canvas c) {
    _fillPaint.color = playerColor;

    double _playerInnerSize = _playerSize / 2.5;

    c.drawCircle(currentSpot, _playerSize, _fillPaint);
    c.drawCircle(currentSpot, _playerSize, _strokePaint);

    _fillPaint.color = Colors.white;
    c.drawCircle(currentSpot, _playerInnerSize, _fillPaint);
    c.drawCircle(currentSpot, _playerInnerSize, _strokePaint);

    _fillPaint.color = Colors.pink;
    rect = Rect.fromLTRB(
      currentSpot.dx - _playerSize,
      currentSpot.dy - _playerSize,
      currentSpot.dx + _playerSize,
      currentSpot.dy + _playerSize,
    );
    // c.drawRect(rect, _fillPaint);
  }

  bool get isInBase => currentSpot == spawn;

  void moveTo(int steps) {
    if (_currentStep < path.length) {
      // currentSpot = path[_currentStep++];
      currentSpot = path[49];
    } else {
      atCenter = true;
    }
  }

  void update(double t) {}

  void resize() {
    _screenSize = game.screenSize;

    if (_screenSize.aspectRatio > 1) {
      _playerSize = _screenSize.height * 0.01;
    } else {
      _playerSize = _screenSize.width * 0.01;
    }

    if (_currentStep == 0) {
      currentSpot = spawn;
    } else {
      currentSpot = path[_currentStep - 1];
    }
  }

  void onTapDown() {}

  String toString() => "${this.playerColor.value}, ${this.currentSpot}";
}
