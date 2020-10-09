import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'models/player.dart';
import 'state.dart';
import 'util/util.dart';

class Ludo extends Game with TapDetector {
  static const _START_NUMBER = 6;

  Size screenSize;

  StateGame _state;
  StartButton _startButton;

  Board _board;

  // ScoreBoard _scoreBoard;
  Dice _dice;

  List<Player> _players;
  List<Token> _tokens;

  bool _shouldMove;
  int _currentPlayer;

  int numPlayers;

  void initialize() async {
    resize(await Flame.util.initialDimensions());

    _state = StateGame.menu;
    _board = Board(this);
    _players = List<Player>();
    _dice = Dice(this);
    _tokens = List<Token>();
    // _scoreBoard = ScoreBoard(this);
    _startButton = StartButton(this);
  }

  Ludo() {
    initialize();
  }

  @override
  void render(Canvas c) {
    _drawBackground(c);
    _board.render(c);

    if (_tokens.isEmpty) initTokens();

    if (_state == StateGame.menu) {
      _startButton.render(c);
    } else {
      // _scoreBoard.render(c);
      _dice.render(c);
      _tokens.forEach((p) => p.render(c));
    }
  }

  void _drawBackground(Canvas c) {
    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = AppColors.backgroundColor;

    c.drawRect(background, backgroundPaint);
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
          path: _board.paths[i],
        ));
      }
    }

    _tokens.forEach((p) => p.resize());
  }

  void startGame() {
    _state = StateGame.playing;

    _initPlayers();

    _currentPlayer = -1;
    _nextPlayer();
  }

  void _nextPlayer() {
    _currentPlayer = (++_currentPlayer) % 4;

    // _scoreBoard.setInfo(
    //   playerColor: _players[_currentPlayer].playerColor,
    //   playerName: _players[_currentPlayer].name,
    //   lastNumber: _dice.number,
    // );

    _board.currentPlayer = _currentPlayer;

    _shouldMove = false;
    _dice.canRoll = true;
  }

  void _initPlayers() {
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(0, 4),
      name: 'Green',
      id: 0,
    ));
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(4, 8),
      name: 'Red',
      id: 1,
    ));
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(8, 12),
      name: 'Blue',
      id: 2,
    ));
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(12, 16),
      name: 'Yellow',
      id: 3,
    ));
  }

  void update(double t) {
    if (_state == StateGame.playing) {
      _board.update(t);
      _dice.update(t);
      _tokens.forEach((p) => p.update(t));
      // _scoreBoard.update(t);
    }
  }

  void resize(Size size) {
    screenSize = size;

    // _scoreBoard?.resize();
    _board?.resize();
    _dice?.resize();

    if (_state == StateGame.menu) {
      _startButton?.resize();
    } else if (_state == StateGame.playing) {
      for (Player p in _players) {
        for (Token t in p.tokens) {
          t.spawn = _board.spawnSpots[t.id];
          t.path = _board.paths[t.homeId];
          t.resize();
        }
      }
    }
  }

  bool c = false;

  void onTapDown(TapDownDetails d) {
    if (_state == StateGame.menu) {
      if (_startButton.checkClick(d.localPosition)) {
        _shouldMove = false;
        _dice.canRoll = true;
        _state = StateGame.playing;
        startGame();
      }
    } else if (_state == StateGame.playing) {
      final p = _players[1];
      for (Token t in p.tokens) {
        if (t.rect.contains(d.localPosition)) {
          t.moveTo(33);
        }
      }
    }
  }
}

// if (_dice.canRoll && _dice.checkClick(d.localPosition)) {
// _dice.roll();
//
// if (_dice.number != _START_NUMBER && !p.haveTokenOutBase) {
// _nextPlayer();
// } else {
// _dice.canRoll = false;
// _shouldMove = true;
// }
// } else if (_shouldMove) {
// for (Token t in p.tokens) {
// if (t.rect.contains(d.localPosition)) {
// if (t.isInBase && _dice.number == 6) {
// t.moveTo(0);
// _shouldMove = false;
// _dice.canRoll = true;
// break;
// } else if (!t.isInBase) {
// t.moveTo(_dice.number);
//
// _nextPlayer();
// break;
// }
// }
// }
// }
