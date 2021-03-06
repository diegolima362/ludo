import 'package:flutter/material.dart';
import 'package:ludo/app/util/colors.dart';

import '../ludo.dart';

class Token {
  final Ludo game;

  final int id;
  final int playerId;
  final int homeId;

  bool atCenter;
  bool isSafe = false;
  bool activePlayer = false;
  bool canLeaveBase = false;
  final String colorName;

  List<Offset> path;

  Rect _rect;
  Color playerColor;

  Paint _fillPaint;
  Paint _strokePaint;

  Offset currentSpot;
  Offset spawn;
  Offset start;
  Offset finish;

  Size _screenSize;

  double _playerSize;
  double _stepSize;

  int _currentStep;

  double _counter;

  Token({
    @required this.id,
    @required this.playerId,
    @required this.homeId,
    @required this.colorName,
    @required this.game,
    @required this.spawn,
    @required this.playerColor,
    @required this.path,
    this.start,
    this.finish,
  }) {
    _counter = 0;
    atCenter = false;
    _currentStep = start != null ? 0 : -1;
    currentSpot = start ?? spawn;
    _fillPaint = Paint();
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;

    resize();
  }

  int get currentStep => _currentStep;

  bool get isInBase => currentSpot == spawn;

  void render(Canvas c) {
    _fillPaint.color = playerColor;

    if ((!isInBase || canLeaveBase) &&
        !atCenter &&
        activePlayer &&
        _counter.toInt() == 1) {
      final step = Rect.fromLTWH(
        currentSpot.dx - _stepSize / 2,
        currentSpot.dy - _stepSize / 2,
        _stepSize,
        _stepSize,
      );
      _fillPaint.color = AppColors.activeHome;
      c.drawRect(step, _fillPaint);
      _fillPaint.color = playerColor;
    }

    double _playerInnerSize = _playerSize / 2.5;

    c.drawCircle(currentSpot, _playerSize, _fillPaint);
    c.drawCircle(currentSpot, _playerSize, _strokePaint);

    _fillPaint.color = Colors.white;
    c.drawCircle(currentSpot, _playerInnerSize, _fillPaint);
    c.drawCircle(currentSpot, _playerInnerSize, _strokePaint);

    _fillPaint.color = Colors.pink;
    _rect = Rect.fromLTRB(
      currentSpot.dx - _playerSize,
      currentSpot.dy - _playerSize,
      currentSpot.dx + _playerSize,
      currentSpot.dy + _playerSize,
    );
    // c.drawRect(rect, _fillPaint);
  }

  bool move(int steps) {
    if (atCenter) return false;

    int last = _currentStep;

    if (isInBase) {
      currentSpot = path[++_currentStep];

      print('> move token:$colorName:${id % 4} from home to $_currentStep');

      return true;
    } else if (_currentStep + steps <= path.length) {
      _currentStep += steps;

      if (_currentStep == path.length) {
        atCenter = true;
        currentSpot = finish;
      } else {
        currentSpot = path[_currentStep];
      }

      isSafe = false;

      print(
        '> move token $colorName:${id % 4} from $last to ${atCenter ? 'center' : _currentStep == -1 ? 'home' : _currentStep} ',
      );

      return true;
    }

    return false;
  }

  void update(double t) {
    _counter += t;

    if (_counter >= 2) {
      _counter -= 2;
    }
  }

  void resize() {
    _screenSize = game.screenSize;

    if (_screenSize.aspectRatio > 1) {
      _playerSize = _screenSize.height * 0.01;
      _stepSize = _screenSize.height * 0.035;
    } else {
      _playerSize = _screenSize.width * 0.01;
      _stepSize = _screenSize.width * 0.035;
    }

    if (_currentStep == -1) {
      currentSpot = start ?? spawn;
    } else if (atCenter) {
      currentSpot = finish;
    } else {
      currentSpot = path[_currentStep];
    }
  }

  void onTapDown() {}

  String toString() => "${this.playerColor.value}, ${this.currentSpot}";

  void backToBase() {
    _currentStep = -1;
    currentSpot = start = spawn;

    print('> token $colorName:${id % 4} goes back to home');
  }

  bool checkConflict(Offset o) {
    if (o == null)
      return false;
    else
      return currentSpot.dx.floorToDouble() == o.dx.floorToDouble() &&
          currentSpot.dy.floorToDouble() == o.dy.floorToDouble();
  }

  bool get canMove => !atCenter;

  bool checkMove(int steps) =>
      canMove &&
      ((isInBase && steps >= 9) || !isInBase) &&
      _currentStep + steps <= path.length;

  bool checkClick(Offset o) => _rect.contains(o);

  bool canReachCenter(int steps) => _currentStep + steps == path.length;

  Offset futurePosition(int steps) {
    if (_currentStep + steps < path.length)
      return path[_currentStep + steps];
    else
      return null;
  }
}
