import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import 'util/util.dart';

class Ludo extends Game with TapDetector {
  Size screenSize;

  void initialize() async {}

  Ludo() {
    initialize();
  }

  @override
  void render(Canvas c) {
    _drawBackground(c);
  }

  void _drawBackground(Canvas c) {
    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = AppColors.backgroundColor;

    c.drawRect(background, backgroundPaint);
  }

  @override
  void update(double t) {}

  @override
  void resize(Size size) {
    screenSize = size;
  }

  @override
  void onTapDown(TapDownDetails d) {}
}
