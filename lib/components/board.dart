import 'dart:math';

import 'package:flutter/material.dart';

import '../ludo.dart';
import '../util/util.dart';

class Board {
  static const int _PATH_LENGTH = 8;
  static const int _NUM_LINES = 3;
  static const int _NUM_HOMES = 4;
  static const int _SAFE_SPOT = 4;

  final Ludo game;

  Map<int, Offset> homeSpots;
  Map<int, Offset> spawnSpots;
  Map<int, Offset> safeSpots;
  Map<int, Offset> initialPositions;

  int currentPlayer;

  double _horizontalCenter;
  double _verticalCenter;
  double _stepSize;
  double _pathSize;
  double _homeSize;

  Size _screenSize;

  Rect _homeBorder;
  Rect _innerHome;

  Paint _fillPaint;
  Paint _strokePaint;

  double _counter;

  Board(this.game) {
    homeSpots = Map<int, Offset>();
    spawnSpots = Map<int, Offset>();
    initialPositions = Map<int, Offset>();

    _fillPaint = Paint();

    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.black;

    _counter = 0;
  }

  List<Offset> paths = List<Offset>();

  void render(Canvas c) {
    _fillPaint.color = Colors.white;

    final border = Rect.fromLTWH(
      _horizontalCenter - _homeSize - (_pathSize / 2) - _stepSize,
      _verticalCenter - _homeSize - (_pathSize / 2) - _stepSize,
      (2 * _homeSize) + _pathSize + (2 * _stepSize),
      (2 * _homeSize) + _pathSize + (2 * _stepSize),
    );
    c.drawRect(border, _fillPaint);
    c.drawRect(border, _strokePaint);

    _drawHomes(c);
    _drawSteps(c);
    _drawCenter(c);
  }

  void _drawHomes(Canvas c) {
    final innerHomeSize = _homeSize - 2 * _stepSize;

    int k = 0;
    double spotRadius = _stepSize * .8;

    for (int i = 0; i < _NUM_HOMES; i++) {
      if (i == currentPlayer && _counter.toInt() == 1) {
        _fillPaint.color = AppColors.activeHome;
      } else {
        _fillPaint.color = AppColors.colors[i];
      }

      _homeBorder =
          Rect.fromLTWH(homeSpots[i].dx, homeSpots[i].dy, _homeSize, _homeSize);
      c.drawRect(_homeBorder, _fillPaint);
      c.drawRect(_homeBorder, _strokePaint);

      _fillPaint.color = Colors.white;
      _innerHome = Rect.fromLTWH(
        _homeBorder.left + _stepSize,
        _homeBorder.top + _stepSize,
        innerHomeSize,
        innerHomeSize,
      );
      c.drawRect(_innerHome, _fillPaint);
      c.drawRect(_innerHome, _strokePaint);

      _fillPaint.color = AppColors.colors[i];

      for (int i = 0; i < _NUM_HOMES; i++) {
        final spot = spawnSpots[k++];

        c.drawCircle(spot, spotRadius, _fillPaint);
        c.drawCircle(spot, spotRadius, _strokePaint);
      }
    }
  }

  void _drawSteps(Canvas c) {
    Rect step;

    for (int homeIndex = 0; homeIndex < 4; homeIndex++) {
      _fillPaint.color = AppColors.colors[homeIndex];

      for (int line = 0; line < _NUM_LINES; line++) {
        for (int pos = 0; pos < _PATH_LENGTH; pos++) {
          step = Rect.fromLTWH(
            (pos * _stepSize) +
                (_horizontalCenter - _homeSize - (_pathSize / 2)),
            (line * _stepSize) + _verticalCenter - (_pathSize / 2),
            _stepSize,
            _stepSize,
          );

          if (pos == _SAFE_SPOT && line == 2) {
            _fillPaint.color = AppColors.safeSpot;
            c.drawRect(step, _fillPaint);
            _fillPaint.color = AppColors.colors[homeIndex];
          }

          if (pos == 1 && line == 0)
            c.drawRect(step, _fillPaint);
          else if (pos > 0 && line == 1) c.drawRect(step, _fillPaint);

          c.drawRect(step, _strokePaint);
        }
      }

      c.translate(_verticalCenter, _verticalCenter);
      c.rotate(pi / 2);
      c.translate(-_horizontalCenter, -_horizontalCenter);
    }
  }

  void _drawCenter(Canvas c) {
    for (int i = 0; i < _NUM_HOMES; i++) {
      _fillPaint.color = AppColors.colors[i];

      final finish = Path()
        ..moveTo(_horizontalCenter, _verticalCenter)
        ..lineTo(
          _horizontalCenter - (1.5 * _stepSize),
          _verticalCenter - (1.5 * _stepSize),
        )
        ..lineTo(
          _horizontalCenter - (1.5 * _stepSize),
          _verticalCenter + (1.5 * _stepSize),
        )
        ..close();

      c.drawPath(finish, _fillPaint);
      c.drawPath(finish, _strokePaint);

      c.translate(_verticalCenter, _verticalCenter);
      c.rotate(pi / 2);
      c.translate(-_horizontalCenter, -_horizontalCenter);
    }
  }

  void resize() {
    _screenSize = game.screenSize;

    if (_screenSize.aspectRatio > 1) {
      _stepSize = _screenSize.height * 0.035;
    } else {
      _stepSize = _screenSize.width * 0.035;
    }

    _pathSize = _stepSize * _NUM_LINES;
    _homeSize = _stepSize * 8;
    _horizontalCenter = _screenSize.width / 2;
    _verticalCenter = (_screenSize.height / 2) - 1.5 * _stepSize;

    homeSpots[0] = Offset(
      _horizontalCenter - _homeSize - (_pathSize / 2),
      _verticalCenter - _homeSize - (_pathSize / 2),
    );

    homeSpots[1] = Offset(
      _horizontalCenter + (_pathSize / 2),
      _verticalCenter - _homeSize - (_pathSize / 2),
    );

    homeSpots[2] = Offset(
      _horizontalCenter + (_pathSize / 2),
      _verticalCenter + (_pathSize / 2),
    );

    homeSpots[3] = Offset(
      _horizontalCenter - _homeSize - (_pathSize / 2),
      _verticalCenter + (_pathSize / 2),
    );

    final d = _homeSize - 2 * _stepSize;
    _homeBorder = Rect.fromLTWH(
      _horizontalCenter - _homeSize - (_pathSize / 2),
      _verticalCenter - _homeSize - (_pathSize / 2),
      _homeSize,
      _homeSize,
    );

    _innerHome = Rect.fromLTWH(
      _homeBorder.left + _stepSize,
      _homeBorder.top + _stepSize,
      d,
      d,
    );

    double offset = _innerHome.width / 4;

    double x;
    double y;
    int k = 0;

    for (int i = 0; i < 4; i++) {
      x = _innerHome.center.dx +
          (i == 1 || i == 2 ? _homeSize + (2 * offset) : 0);
      y = _innerHome.center.dy +
          (i == 2 || i == 3 ? _homeSize + (2 * offset) : 0);

      spawnSpots[k++] = Offset(x - offset, y - offset);
      spawnSpots[k++] = Offset(x + offset, y - offset);
      spawnSpots[k++] = Offset(x + offset, y + offset);
      spawnSpots[k++] = Offset(x - offset, y + offset);
    }

    x = _horizontalCenter - _homeSize;
    y = _verticalCenter - _stepSize;
    initialPositions[0] = Offset(x, y);

    x = _horizontalCenter + _stepSize;
    y = _verticalCenter - _homeSize;
    initialPositions[1] = Offset(x, y);

    x = _horizontalCenter + _homeSize;
    y = _verticalCenter + _stepSize;

    initialPositions[2] = Offset(x, y);
    x = _horizontalCenter - _stepSize;

    y = _verticalCenter + _homeSize;
    initialPositions[3] = Offset(x, y);

    paths.clear();
    _calculateRoute(0);
  }

  void _calculateRoute(int id) {
    paths.add(initialPositions[id]);

    double x;
    double y;
    x = initialPositions[id].dx;
    y = initialPositions[id].dy;

    x = _goRight(6, x, y);

    paths.add(Offset(x += _stepSize, y -= _stepSize));

    y = _goUp(7, x, y);
    x = _goRight(2, x, y);
    y = _goDown(6, x, y);

    paths.add(Offset(x += _stepSize, y+=_stepSize));

    x = _goRight(7, x, y);
    y = _goDown(1, x, y);
    x = _goLeft(7, x, y);

    paths.add(Offset(x -= _stepSize, y += _stepSize));

    y = _goDown(6, x, y);
    x = _goLeft(2, x, y);
    y = _goUp(7, x, y);

    paths.add(Offset(x -= _stepSize, y -= _stepSize));

    x = _goLeft(7, x, y);
    y = _goUp(1, x, y);
    x = _goRight(8, x, y);
  }

  double _goUp(int n, double x, double y) {
    for (int i = 0; i <= n - 1; i++) {
      paths.add(Offset(x, y -= _stepSize));
    }

    return y;
  }

  double _goDown(int n, double x, double y) {
    for (int i = 0; i <= n; i++) {
      paths.add(Offset(x, y += _stepSize));
    }

    return y;
  }

  double _goLeft(int n, double x, double y) {
    for (int i = 0; i <= n - 1; i++) {
      paths.add(Offset(x -= _stepSize, y));
    }
    return x;
  }

  double _goRight(int n, double x, double y) {
    for (int i = 0; i <= n - 1; i++) {
      paths.add(Offset(x += _stepSize, y));
    }
    return x;
  }

  void update(double t) {
    _counter += 3 * t;

    if (_counter >= 2) {
      _counter -= 2;
    }
  }
}
