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
    Paint backgroundPaint = Paint()
      ..color = AppColors.backgroundColor;

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

  void update(double t) {
    if (_state == StateGame.playing) {
      _board.update(t);
      _dice.update(t);
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
      _tokens.forEach((t) => t.resize());
    }
  }

  void onTapDown(TapDownDetails d) {
    if (_state == StateGame.menu) {
      if (_startButton.checkClick(d.localPosition)) {
        _shouldMove = false;
        _dice.canRoll = true;
        _state = StateGame.playing;
        startGame();
      }
    } else if (_state == StateGame.playing) {
      final p = _players[_currentPlayer];
      if (_dice.canRoll && _dice.checkClick(d.localPosition)) {
        _dice.roll();

        if (_dice.number != 6 && !p.haveTokenOutBase) {
          _nextPlayer();
        } else {
          _dice.canRoll = false;
          _shouldMove = true;
        }
      } else if (_shouldMove) {
        for (Token t in p.tokens) {
          if (t.rect.contains(d.localPosition)) {
            if (t.isInBase && _dice.number == 6) {
              t.moveTo(_board.initialPositions[t.homeId]);
              _shouldMove = false;
              _dice.canRoll = true;
              break;
            } else if (!t.isInBase) {
              t.moveTo(Offset(_dice.number * 50.0, (_dice.number / 2) * 50.0));

              _nextPlayer();
              break;
            }
          }
        }
      }
    }
  }
}
