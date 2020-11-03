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
  static const _ALERT_TIME = 5;

  Size screenSize;

  StateGame _state;
  StartButton _startButton;

  Board _board;
  List<Offset> withPlayer;
  ScoreBoard _scoreBoard;
  Dice _dice;
  Timer _timerPlay;
  Timer _timerDice;

  List<Player> _players;
  List<Token> _tokens;

  bool _shouldMove;
  int _currentPlayer;

  int humanId;
  int numPlayers;
  int activePlayers;
  bool useTimeLimit;
  int limitTime;
  bool fastMode;

  Player winner;

  int _currentPlayMoves;
  int _currentPlayDiceSum;

  Ludo() {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());

    humanId = 3;
    activePlayers = 2;
    numPlayers = 4;
    limitTime = 10;
    useTimeLimit = false;
    fastMode = true;

    _currentPlayer = 0;
    _currentPlayMoves = 0;
    _currentPlayDiceSum = 0;

    withPlayer = List<Offset>();

    _state = StateGame.menu;
    _board = Board(this);
    _players = List<Player>();
    _dice = Dice(this);
    _timerPlay = Timer(this);
    _timerDice = Timer(this);
    _tokens = List<Token>();

    _scoreBoard = ScoreBoard(this);
    _startButton = StartButton(this);
  }

  void startGame() {
    _currentPlayer = 0;
    _currentPlayMoves = 0;
    _currentPlayDiceSum = 0;

    winner = null;

    _state = StateGame.playing;

    _initPlayers();

    _currentPlayer = -1;
    _nextPlayer();
  }

  void _endGame() {
    withPlayer.clear();
    _players.clear();
    _tokens.clear();

    _timerPlay.reset();
    _timerDice.reset();

    _state = StateGame.menu;
  }

  void _nextPlayer() {
    _calculateCurrentPlayerScore();
    _currentPlayer = (++_currentPlayer) % 4;

    _scoreBoard.setInfo(
      playerColor: _players[_currentPlayer].playerColor,
      playerName: _players[_currentPlayer].name,
      lastNumber: _dice.number,
      score: _players[_currentPlayer].score,
    );

    _board.currentPlayer = _currentPlayer;
    _board.currentPlayer = _currentPlayer;

    _tokens.forEach((t) {
      t.activePlayer = t.playerId == _currentPlayer;
    });

    _currentPlayMoves = 0;
    _currentPlayDiceSum = 0;
    _shouldMove = false;
    _dice.canRoll = true;
    _timerPlay.reset();
    _timerDice.reset();
  }

  void _initPlayers() {
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(0, 4),
      name: 'Green',
      id: 0,
    ));
    _players.add(Player(
      playerColor: AppColors.player2,
      tokens: _tokens.sublist(4, 8),
      name: 'Red',
      id: 1,
    ));
    _players.add(Player(
      playerColor: AppColors.player3,
      tokens: _tokens.sublist(8, 12),
      name: 'Blue',
      id: 2,
    ));
    _players.add(Player(
      playerColor: AppColors.player4,
      tokens: _tokens.sublist(12, 16),
      name: 'Yellow',
      id: 3,
    ));
  }

  void _checkAtack(Offset o) {
    for (Player p in _players) {
      if (p.id != _currentPlayer) {
        for (Token t in p.tokens) {
          if (t.checkConflict(o)) {
            if (!t.isSafe) {
              t.backToBase();
            }
          }
        }
      }
    }
  }

  void _makeRandomMove() {
    _players[_currentPlayer].closerToken.move(1);
    _nextPlayer();
  }

  void _calculateCurrentPlayerScore() {
    final p = _players[_currentPlayer == -1 ? 0 : _currentPlayer];
    p.time += _timerPlay.remainingTime ?? 0 - _timerDice.remainingTime ?? 0;
    p.plays += _currentPlayMoves ?? 0;
    p.diceSum += _currentPlayDiceSum ?? 0;
  }

  void _drawBackground(Canvas c) {
    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = AppColors.backgroundColor;

    c.drawRect(background, backgroundPaint);
  }

  void _initTokens() {
    final spawns = List<Offset>();
    final finish = List<Offset>();
    _board.spawnSpots.forEach((key, value) => spawns.add(value));
    _board.finishSpots.forEach((key, value) => finish.add(value));

    int k = 0;

    for (int i = 0; i < 4; i++) {
      var _path = _board.paths[i];
      for (int j = 0; j < 4; j++) {
        _tokens.add(
          Token(
            game: this,
            id: k,
            homeId: i,
            spawn: spawns[k],
            start: j == 3 && i == 0 || j + 1 % 4 == i ? _path[0] : null,
            playerColor: AppColors.colors[i],
            path: _path,
            finish: finish[k],
            playerId: i,
          ),
        );
        k++;
      }
    }

    _tokens.forEach((p) => p.resize());
  }

  void _handlePlay(TapDownDetails d) {
    final p = _players[_currentPlayer];

    if (_dice.canRoll && _dice.checkClick(d.localPosition)) {
      _dice.roll();
      _dice.canRoll = false;
      _currentPlayDiceSum += _dice.number;
      _shouldMove = true;
    } else if (_shouldMove) {
      _dice.number = 1;
      if (true) {
        if (p.haveTokenOutBase || p.haveTokenInBase) {
          for (Token t in p.tokens) {
            if (t.checkClick(d.globalPosition) &&
                t.checkMovement(_dice.number)) {
              _makeMove(t);
              // t.backToBase();
              // _shouldMove = false;
              // _dice.canRoll = true;
              return;
            }
          }
        } else {
          _nextPlayer();
        }
      } else if (p.haveTokenOutBase) {
        for (Token t in p.tokens) {
          if (t.checkClick(d.globalPosition) &&
              !t.isInBase &&
              t.checkMovement(_dice.number)) {
            _makeMove(t);
            // t.backToBase();

            _nextPlayer();
            return;
          }
        }
      } else if (!p.haveTokenOutBase) {
        _nextPlayer();
      }
    }
  }

  void _makeMove(Token t, {int steps}) {
    Offset position = t.currentSpot;

    withPlayer.remove(position);

    t.move(steps ?? _dice.number == 0 ? 10 : _dice.number);

    position = t.currentSpot;

    if (_checkConflict(position)) _checkAtack(position);

    withPlayer.add(position);

    if (Board.safeIndex.contains(t.currentStep)) t.isSafe = true;

    if (t.atCenter && fastMode) winner = _players[t.playerId];
  }

  bool _checkConflict(Offset o) {
    for (Offset a in withPlayer) {
      if (a.dx.floorToDouble() == o.dx.floorToDouble() &&
          a.dy.floorToDouble() == o.dy.floorToDouble()) return true;
    }

    return false;
  }

  @override
  void render(Canvas c) {
    _drawBackground(c);
    _board.render(c);

    if (_tokens.isEmpty) _initTokens();

    if (_state == StateGame.menu) {
      _startButton.render(c);
    } else {
      _scoreBoard.render(c);
      _dice.render(c);
      if (useTimeLimit) {
        if (_shouldMove && _timerPlay.remainingTime < _ALERT_TIME)
          _timerPlay.render(c);
        if (_dice.canRoll && _timerDice.remainingTime <= _ALERT_TIME)
          _timerDice.render(c);
      }
      _tokens.forEach((p) => p.render(c));
    }
  }

  void update(double t) {
    if (_state == StateGame.playing) {
      _board.update(t);
      _dice.update(t);

      if (useTimeLimit) {
        if (_shouldMove) {
          _timerPlay.update(t);
          if (_timerPlay.remainingTime == 0) _makeRandomMove();
        }

        if (_dice.canRoll) {
          _timerDice.update(t);
          if (_timerDice.remainingTime == 0) _makeRandomMove();
        }
      }

      _tokens.forEach((p) => p.update(t));
      _scoreBoard.update(t);

      if (winner != null) {
        _endGame();
      }
    }
  }

  void resize(Size size) {
    screenSize = size;

    _scoreBoard?.resize();
    _board?.resize();
    _dice?.resize();
    _timerPlay?.resize();
    _timerDice?.resize();

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

  void onTapDown(TapDownDetails d) {
    if (_state == StateGame.menu) {
      if (_startButton.checkClick(d.localPosition)) {
        _shouldMove = false;
        _dice.canRoll = true;
        startGame();
      }
    } else if (_state == StateGame.playing) {
      _handlePlay(d);
    }
  }
}
