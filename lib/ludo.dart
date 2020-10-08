import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'models/player.dart';
import 'util/util.dart';

class Ludo extends Game with TapDetector {
  Size screenSize;

  Board _board;

  List<Player> _players;
  List<Token> _tokens;

  int _currentPlayer;

  int numPlayers;

  void initialize() async {
    _board = Board(this);
    _players = List<Player>();
    _tokens = List<Token>();
  }

  Ludo() {
    initialize();
  }

  void startGame() {
    _initPlayers();

    _currentPlayer = -1;
    _nextPlayer();
  }

  void _nextPlayer() {
    _currentPlayer = (++_currentPlayer) % numPlayers;

    _board.currentPlayer = _currentPlayer;
  }

  void _initPlayers() {
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(0, 4),
      name: 'Green',
    ));
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(4, 7),
      name: 'Red',
    ));
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(8, 11),
      name: 'Blue',
    ));
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(12, 15),
      name: 'Yellow',
    ));
  }

  void initTokens() {
    final spawns = List<Offset>();
    _board.spawnSpots.forEach((key, value) => spawns.add(value));

    int k = 0;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        _tokens.add(Token(
          game: this,
          id: k,
          homeId: i,
          spawn: spawns[k++],
          playerColor: AppColors.colors[i],
        ));
      }
    }

    _tokens.forEach((p) => p.resize());
  }

  @override
  void render(Canvas c) {
    _drawBackground(c);
    _board.render(c);

    if (_tokens.isEmpty) initTokens();

    _tokens.forEach((p) => p.render(c));
  }

  void _drawBackground(Canvas c) {
    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = AppColors.backgroundColor;

    c.drawRect(background, backgroundPaint);
  }

  @override
  void update(double t) {
    _board.update(t);
  }

  @override
  void resize(Size size) {
    screenSize = size;

    _board?.resize();

    _tokens.forEach((t) => t.resize());
  }

  @override
  void onTapDown(TapDownDetails d) {}
}
