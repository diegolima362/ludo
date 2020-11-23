import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ludo/components/exit_button.dart';
import 'package:ludo/components/restart_game_button.dart';
import 'package:ludo/views/winner_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/components.dart';
import 'game_mode.dart';
import '../models/player.dart';
import 'state.dart';
import '../util/util.dart';

class Ludo extends Game with TapDetector {
  static const _ALERT_TIME = 5;
  static const _CPU_WAIT = 2;

  Size screenSize;

  final BuildContext context;
  final SharedPreferences storage;

  StateGame state;
  final GameMode gameMode;
  final String playerName;

  StartButton _startButton;
  ExitButton _exitButton;
  RestartGameButton _restartButton;

  Board _board;
  List<Offset> withPlayer;
  ScoreBoard _scoreBoard;
  WinnerView _winnerView;
  Dice _dice;
  Timer _timerPlay;
  Timer _timerDice;

  List<Player> _players;
  List<Token> _tokens;

  bool _shouldMove;
  int _currentPlayer;

  final bool useTimeLimit;
  final int timeLimit;

  int humanId;
  int numPlayers;
  int activePlayers;
  bool fastMode;
  Player winner;

  int _currentPlayMoves;
  int _currentPlayDiceSum;

  double _counterTimer;

  bool _cpuTurn;

  Ludo(
      {@required this.context,
      @required this.storage,
      this.useTimeLimit = false,
      this.timeLimit = 10,
      this.gameMode = GameMode.normal,
      this.playerName}) {
    initialize();
  }

  Future<void> initialize() async {
    resize(await Flame.util.initialDimensions());

    humanId = 3;
    activePlayers = 2;
    numPlayers = 4;

    fastMode = gameMode == GameMode.fast;

    _currentPlayer = 0;
    _currentPlayMoves = 0;
    _currentPlayDiceSum = 0;

    _counterTimer = 0;
    _cpuTurn = false;

    withPlayer = List<Offset>();

    state = StateGame.menu;

    _board = Board(this);
    _winnerView = WinnerView(this);
    _players = List<Player>();
    _dice = Dice(this);
    _timerPlay = Timer(this);
    _timerDice = Timer(this);
    _tokens = List<Token>();

    _scoreBoard = ScoreBoard(this);
    _startButton = StartButton(this);
    _exitButton = ExitButton(this);
    _restartButton = RestartGameButton(this);
  }

  void startGame() {
    _currentPlayer = fastMode ? 1 : 1;
    _currentPlayMoves = 0;
    _currentPlayDiceSum = 0;

    winner = null;

    state = StateGame.playing;

    _initPlayers();

    _currentPlayer = -1;
    _nextPlayer();
  }

  void _restart() {
    withPlayer.clear();
    _players.clear();
    _tokens.clear();

    _timerPlay.reset();
    _timerDice.reset();

    state = StateGame.menu;
  }

  void _endGame() {
    state = StateGame.winner;
  }

  void _nextPlayer() {
    _calculateCurrentPlayerScore();

    if (_cpuTurn) {
      print('> end of cpu turn');
    } else {
      print('> end of player turn');
    }

    if (fastMode) {
      _currentPlayer = (++_currentPlayer) % 4;
    } else {
      _currentPlayer = _currentPlayer == 3 ? 1 : 3;
    }

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

    if (fastMode && (_currentPlayer == 0 || _currentPlayer == 2)) {
      print('> cpu turn');
      _cpuTurn = true;
      _makeCPUMove();
    } else if (_currentPlayer == 1 && !fastMode) {
      print('> cpu turn');
      _cpuTurn = true;
      _makeCPUMove();
    } else {
      print('> player turn');
      _cpuTurn = false;
    }
  }

  void _initPlayers() {
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(0, 4),
      name: 'CPU',
      id: 0,
    ));
    _players.add(Player(
      playerColor: AppColors.player2,
      tokens: _tokens.sublist(4, 8),
      name: fastMode ? playerName : 'CPU',
      id: 1,
    ));
    _players.add(Player(
      playerColor: AppColors.player3,
      tokens: _tokens.sublist(8, 12),
      name: 'CPU',
      id: 2,
    ));
    _players.add(Player(
      playerColor: AppColors.player4,
      tokens: _tokens.sublist(12, 16),
      name: playerName,
      id: 3,
    ));
  }

  void _checkAttack(Token t) {
    for (Player p in _players) {
      if (p.id != _currentPlayer) {
        if (fastMode && _sameTeam(p)) return;
        for (Token t2 in p.tokens) {
          if (t2.checkConflict(t.currentSpot)) {
            if (!t2.isSafe) {
              print(
                  '> token ${t.colorName}:${t.id % 4} attacked token ${t2.colorName}:${t2.id % 4}');
              t2.backToBase();
            }
          }
        }
      }
    }
  }

  bool _sameTeam(Player p) {
    return _currentPlayer % 2 == 0 && p.id % 2 == 0 ||
        (_currentPlayer % 2 != 0 && p.id % 2 != 0);
  }

  void _makeRandomMove() {
    print('> random move');
    _players[_currentPlayer].closerToken.move(1);
    _nextPlayer();
  }

  void _calculateCurrentPlayerScore() {
    final p = _players[_currentPlayer == -1 ? 0 : _currentPlayer];
    p.plays += _currentPlayMoves ?? 0;
    p.diceSum += _currentPlayDiceSum ?? 0;

    if (useTimeLimit)
      p.time += _timerPlay.remainingTime ?? 0 - _timerDice.remainingTime ?? 0;
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
            colorName: AppColors.colorsNames[i],
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

  void testHandle(TapDownDetails d) {
    _currentPlayer = 3;

    final p = _players[_currentPlayer];

    _dice.number = 15;
    for (Token t in p.tokens) {
      if (t.checkClick(d.globalPosition) && t.checkMovement(_dice.number)) {
        _makeMove(t);
        return;
      }
    }
  }

  void _handlePlay(TapDownDetails d) {
    // testHandle(d);
    // return;

    final p = _players[_currentPlayer];
    final step = _dice.number == 0 ? 10 : _dice.number;

    if (_dice.canRoll && _dice.checkClick(d.localPosition)) {
      _dice.roll();
      _dice.canRoll = false;
      _currentPlayDiceSum += _dice.number;
      _shouldMove = true;
    } else if (_shouldMove) {
      if (step == 10 || step == 9) {
        if (p.haveTokenOutBase || p.haveTokenInBase) {
          bool canMove = false;

          for (Token t in p.tokens) {
            if (!t.isInBase && t.checkMovement(step)) {
              canMove = true;
            }
          }

          if (!canMove) _nextPlayer();

          for (Token t in p.tokens) {
            if (t.checkClick(d.globalPosition) && t.checkMovement(step)) {
              _makeMove(t);
              _shouldMove = false;
              _dice.canRoll = true;
              return;
            }
          }
        } else {
          _nextPlayer();
        }
      } else if (p.haveTokenOutBase) {
        bool canMove = false;

        for (Token t in p.tokens) {
          if (!t.isInBase && t.checkMovement(step)) {
            canMove = true;
          }
        }

        if (!canMove) _nextPlayer();

        for (Token t in p.tokens) {
          if (t.checkClick(d.globalPosition) &&
              !t.isInBase &&
              t.checkMovement(step)) {
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

  void _makeCPUMove() {
    _dice.roll();

    final p = _players[_currentPlayer];

    final step = _dice.number == 0 ? 10 : _dice.number;

    if (step == 10 || step == 9) {
      if (p.haveTokenInBase) {
        for (Token t in p.tokens) {
          if (t.isInBase && t.checkMovement(step)) {
            _makeMove(t);
            _makeCPUMove();
            return;
          }
        }
      } else if (p.haveTokenOutBase) {
        if (p.closerToken.checkMovement(step)) {
          _makeCPUMove();
        } else {
          for (Token t in p.tokens) {
            if (!t.isInBase && t.checkMovement(step)) {
              _makeMove(t);
              _makeCPUMove();
              return;
            }
          }
          _nextPlayer();
        }
      } else {
        _nextPlayer();
      }
    } else if (p.haveTokenOutBase) {
      for (Token t in p.tokens) {
        if (!t.isInBase && t.checkMovement(step)) {
          _makeMove(t);
          _nextPlayer();
          return;
        }
      }
    } else if (!p.haveTokenOutBase) {
      _nextPlayer();
    }

    _nextPlayer();
  }

  void _makeMove(Token t, {int steps}) {
    Offset position = t.currentSpot;

    withPlayer.remove(position);

    t.move(steps ?? _dice.number == 0 ? 10 : _dice.number);

    position = t.currentSpot;

    if (_checkConflict(position)) _checkAttack(t);

    withPlayer.add(position);

    if (Board.safeIndex.contains(t.currentStep)) {
      t.isSafe = true;
      print('> token ${t.id % 4} is in a safe spot');
    }

    _checkWin();
  }

  bool _checkConflict(Offset o) {
    for (Offset a in withPlayer) {
      if (a.dx.floorToDouble() == o.dx.floorToDouble() &&
          a.dy.floorToDouble() == o.dy.floorToDouble()) return true;
    }

    return false;
  }

  void _checkWin() {
    final p = _players[_currentPlayer];
    if (fastMode) {
      for (Token t in p.tokens) {
        if (t.atCenter) winner = p;
      }
    } else {
      if (p.tokens.where((t) => t.atCenter).toList().length == 4) winner = p;
    }
  }

  void _exit() {
    Navigator.pop(context);
  }

  @override
  void render(Canvas c) {
    _drawBackground(c);
    _exitButton.render(c);

    if (state == StateGame.winner) {
      _winnerView.render(c);
      _startButton.render(c);
    } else {
      _board.render(c);

      if (_tokens.isEmpty) _initTokens();

      if (state == StateGame.menu) {
        _startButton.render(c);
      } else {
        _restartButton.render(c);
        _scoreBoard.render(c);

        _dice.render(c);

        if (useTimeLimit) {
          if (_shouldMove && _timerPlay.remainingTime < _ALERT_TIME)
            _timerPlay.render(c);
          if (_dice.canRoll && _timerDice.remainingTime <= _ALERT_TIME)
            _timerDice.render(c);
        }
        if (fastMode) {
          _tokens.forEach((t) => t.render(c));
        } else {
          _players[1].tokens.forEach((p) => p.render(c));
          _players[3].tokens.forEach((p) => p.render(c));
        }
      }
    }
  }

  void update(double t) {
    _counterTimer += t;

    if (_counterTimer > _CPU_WAIT) {
      _counterTimer -= _CPU_WAIT;
    }

    if (state == StateGame.playing) {
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

      if (state == StateGame.winner) _winnerView.update(t);

      _tokens.forEach((p) => p.update(t));
      _scoreBoard.update(t);

      if (winner != null && state == StateGame.playing) {
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
    _exitButton?.resize();

    if (state == StateGame.menu) {
      _startButton?.resize();
    } else if (state == StateGame.winner) {
      _winnerView?.resize();
    } else if (state == StateGame.playing) {
      _restartButton.resize();
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
    if (_exitButton.checkClick(d.localPosition)) {
      _exit();
    }

    if (state == StateGame.winner) {
      if (_startButton.checkClick(d.localPosition)) {
        _restart();
      }
    } else if (state == StateGame.menu) {
      if (_startButton.checkClick(d.localPosition)) {
        _shouldMove = false;
        _dice.canRoll = true;
        startGame();
      }
    } else if (state == StateGame.playing) {
      if (_restartButton.checkClick(d.localPosition)) {
        _restart();
      } else {
        _handlePlay(d);
      }
    }
  }
}
