import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ludo/app/shared/models/score_register.dart';
import 'package:ludo/app/shared/repositories/database.dart';
import 'package:ludo/app/util/colors.dart';

import 'components/components.dart';
import 'game_mode.dart';
import 'models/player.dart';
import 'state.dart';

class Ludo extends Game with TapDetector {
  static const _ALERT_TIME = 5;
  static const _CPU_WAIT = 2;

  Size screenSize;

  final BuildContext context;
  final Database storage;

  StateGame state;
  final GameMode gameMode;
  final String playerName;

  StartButton _startButton;
  ExitButton _exitButton;

  // RestartGameButton _restartButton;

  Board _board;
  ScoreBoard _scoreBoard;
  WinnerDisplay _winnerDisplay;
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
  bool fastMode;
  Player winner;

  int _currentPlayMoves = 0;
  int _currentPlayDiceSum = 0;
  int _currentPlayAttacks = 0;
  double _counterTimer;
  bool _cpuTurn;

  bool _moveByAttack = false;
  bool _moveByReachCenter = false;

  Ludo(
      {@required this.context,
      @required this.storage,
      this.useTimeLimit = false,
      this.timeLimit = 10,
      this.gameMode = GameMode.normal,
      this.playerName}) {
    initialize();
  }

  Player get currentPlayer => _players[_currentPlayer];

  Color get currentPlayerColor => currentPlayer.playerColor;

  Future<void> initialize() async {
    resize(await Flame.util.initialDimensions());

    humanId = 3;
    numPlayers = 4;

    fastMode = gameMode == GameMode.fast;

    _currentPlayer = 0;
    _currentPlayMoves = 0;
    _currentPlayDiceSum = 0;

    _counterTimer = 0;
    _cpuTurn = false;

    state = StateGame.menu;

    _board = Board(this);
    _winnerDisplay = WinnerDisplay(this);
    _players = List<Player>();
    _dice = Dice(this);
    _timerPlay = Timer(this);
    _timerDice = Timer(this);
    _tokens = List<Token>();

    _scoreBoard = ScoreBoard(this);
    _startButton = StartButton(this);
    _exitButton = ExitButton(this);
    // _restartButton = RestartGameButton(this);
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

  void _restart() async {
    state = StateGame.menu;
  }

  Future<void> _endGame() async {
    if (winner.isHuman) {
      int points = _calculateCurrentPlayerScore();

      final date = DateFormat.MMMEd('pt_Br').format(DateTime.now());

      final score = ScoreRegister(
        gameMode: fastMode ? 'fast' : 'normal',
        date: date,
        name: winner.name,
        score: points.toString(),
      );

      await storage.addScore(score);
    }

    state = StateGame.winner;
  }

  void _nextPlayer() {
    final nextTurn = !_moveByAttack && !_moveByReachCenter;

    if (nextTurn) {
      _calculateCurrentPlayerScore();

      _moveByAttack = false;
      _moveByReachCenter = false;

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
      _currentPlayAttacks = 0;
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
  }

  void _initPlayers() {
    _players.add(Player(
      playerColor: AppColors.player1,
      tokens: _tokens.sublist(0, 4),
      name: 'CPU',
      isHuman: false,
      id: 0,
    ));
    _players.add(Player(
      playerColor: AppColors.player2,
      tokens: _tokens.sublist(4, 8),
      name: fastMode ? playerName : 'CPU',
      isHuman: fastMode ? true : false,
      id: 1,
    ));
    _players.add(Player(
      playerColor: AppColors.player3,
      tokens: _tokens.sublist(8, 12),
      name: 'CPU',
      isHuman: false,
      id: 2,
    ));
    _players.add(Player(
      playerColor: AppColors.player4,
      tokens: _tokens.sublist(12, 16),
      name: playerName,
      isHuman: true,
      id: 3,
    ));
  }

  bool _checkAttack(Token t) {
    for (Player p in _players) {
      if (p.id != _currentPlayer) {
        for (Token t2 in p.tokens) {
          if (t2.checkConflict(t.currentSpot)) {
            print('> prepare attack');
            if (!t2.isSafe && !_sameTeam(p)) {
              print(
                  '> token ${t.colorName}:${t.id % 4} attacked token ${t2.colorName}:${t2.id % 4}');
              t2.backToBase();
              _currentPlayAttacks++;
              return true;
            }
            print('> no attacked');
          }
        }
      }
    }

    return false;
  }

  bool _sameTeam(Player p) {
    return fastMode &&
        (_currentPlayer % 2 == 0 && p.id % 2 == 0 ||
            (_currentPlayer % 2 != 0 && p.id % 2 != 0));
  }

  void _makeRandomMove() {
    print('> random move');
    _players[_currentPlayer].closerToken.move(1);
    _nextPlayer();
  }

  int _calculateCurrentPlayerScore() {
    final p = _players[_currentPlayer == -1 ? 0 : _currentPlayer];
    p.plays += _currentPlayMoves ?? 0;
    p.diceSum += _currentPlayDiceSum ?? 0;
    p.enemiesHit += _currentPlayAttacks ?? 0;

    if (useTimeLimit)
      p.time += _timerPlay.remainingTime ?? 0 - _timerDice.remainingTime ?? 0;

    return p.score;
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
    int steps = 10;

    final p = _players[_currentPlayer];

    for (Token t in p.tokens) {
      if (t.checkClick(d.globalPosition) && t.checkMove(steps)) {
        _makeMove(t, steps);
        return;
      }
    }
  }

  void _handlePlay(TapDownDetails d) {
    if (_dice.canRoll && _dice.checkClick(d.localPosition)) {
      _rollDice();
    } else if (_shouldMove) {
      _makeHumanMove(d);
    }
  }

  void _rollDice() {
    _dice.roll();
    _dice.canRoll = false;

    final steps = _dice.number == 0 ? 10 : _dice.number;

    _currentPlayDiceSum += steps;
    _shouldMove = true;

    final p = _players[_currentPlayer];

    p.tokens.forEach((e) {
      if (e.isInBase) e.canLeaveBase = _dice.number == 0 || _dice.number == 9;
    });

    if (!p.checkMovement(steps)) _nextPlayer();
  }

  void _makeHumanMove(TapDownDetails d) {
    int steps;

    if (_moveByAttack || _moveByReachCenter) {
      steps = 10;
      _bonusMove();
    } else {
      steps = _dice.number == 0 ? 10 : _dice.number;
    }

    final p = _players[_currentPlayer];

    if (!p.checkMovement(steps)) {
      _nextPlayer();
      return;
    }

    for (Token t in p.tokens) {
      if (t.checkClick(d.globalPosition)) {
        if (t.isInBase && steps >= 9) {
          _makeMove(t, steps);
          _shouldMove = false;
          _dice.canRoll = true;
          return;
        } else if (t.checkMove(steps)) {
          _makeMove(t, steps);
          _nextPlayer();
          return;
        }
      }
    }
  }

  void _bonusMove() {
    _moveByReachCenter = false;
    _moveByAttack = false;
    _shouldMove = true;
    _dice.canRoll = false;
  }

  void _makeCPUMove() {
    print('> cpu move');

    int steps;

    if (_moveByAttack || _moveByReachCenter) {
      steps = 10;
      _bonusMove();
    } else {
      _dice.roll();
      steps = _dice.number == 0 ? 10 : _dice.number;
    }

    final p = _players[_currentPlayer];

    if (!p.checkMovement(steps)) {
      _nextPlayer();
      return;
    }

    // se um pino consegue chegar ao centro
    // esse pino deve ser priorizado
    for (Token t in p.tokens) {
      if (t.canReachCenter(steps)) {
        _makeMove(t, steps);
        _moveByReachCenter = true;
        _makeCPUMove();
        return;
      }
    }

    // se um pino consegue atacar um pino
    // adversario, a cpu deve fazer o ataque
    for (Token t in p.tokens) {
      if (!t.isInBase && t.checkMove(steps)) {
        for (Player p2 in _players) {
          if (p2.id != _currentPlayer && !_sameTeam(p2)) {
            for (Token t2 in p2.tokens) {
              if (t2.checkConflict(t.futurePosition(steps))) {
                _makeMove(t, steps);
                if (_moveByReachCenter || _moveByAttack)
                  _makeCPUMove();
                else
                  _nextPlayer();
              }
            }
          }
        }
      }
    }

    // se tiver algum pino em base, mova primeiro que puder
    if (steps >= 9) {
      if (p.haveTokenInBase) {
        for (Token t in p.tokens) {
          if (t.isInBase) {
            _makeMove(t, steps);
            _makeCPUMove();
            return;
          }
        }
      }
    }

    if (p.haveMovableToken) {
      if (!p.checkMovement(steps)) _nextPlayer();

      // se o pino mais avancado puder mover os passos
      // ele deve ser priorizado
      if (p.closerToken.checkMove(steps)) {
        _makeMove(p.closerToken, steps);
        if (_moveByReachCenter || _moveByAttack)
          _makeCPUMove();
        else
          _nextPlayer();

        return;
      } else {
        for (Token t in p.tokens) {
          if (t.checkMove(steps)) {
            _makeMove(t, steps);
            if (_moveByReachCenter || _moveByAttack)
              _makeCPUMove();
            else
              _nextPlayer();
            return;
          }
        }
      }
    } else {
      _nextPlayer();
      return;
    }
  }

  void _makeMove(Token t, int steps) {
    t.move(steps);
    if (t.atCenter && !fastMode) {
      _moveByReachCenter = true;
      print('> move by reach center');
    } else {
      _moveByReachCenter = false;
    }

    // if (_checkConflict(position)) {
    //   print('> conflict');
    if (_checkAttack(t)) {
      _moveByAttack = true;
      print('> move by attack');
    } else {
      _moveByAttack = false;
      print('> no attack');
    }
    // }

    if (Board.safeIndex.contains(t.currentStep)) {
      t.isSafe = true;
      print('> token ${t.id % 4} is in a safe spot');
    }

    _currentPlayMoves++;
    _checkWin();
  }

  void _checkWin() {
    final p = _players[_currentPlayer];
    if (fastMode) {
      for (Token t in p.tokens) {
        if (t.atCenter) {
          winner = p;
          print('> winner : $p');
        }
      }
    } else {
      if (p.tokens.where((t) => t.atCenter).toList().length == 4) {
        winner = p;
        print('> winner : $p');
      }
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
      _winnerDisplay.render(c);
      _exitButton.render(c);
    } else {
      _board.render(c);

      if (_tokens.isEmpty) _initTokens();

      if (state == StateGame.menu) {
        _startButton.render(c);
      } else {
        // _restartButton.render(c);
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

      if (state == StateGame.winner) _winnerDisplay.update(t);

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
    _startButton?.resize();
    _winnerDisplay?.resize();

    if (state == StateGame.playing) {
      // _restartButton.resize();
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
      if (_exitButton.checkClick(d.localPosition)) {
        state = StateGame.menu;
      }
    } else if (state == StateGame.menu) {
      if (_startButton.checkClick(d.localPosition)) {
        _shouldMove = false;
        _dice.canRoll = true;
        startGame();
      }
    } else if (state == StateGame.playing) {
      _handlePlay(d);
      // if (_restartButton.checkClick(d.localPosition)) {
      //   _shouldMove = false;
      //   _dice.canRoll = true;
      //   startGame();
      // } else {
      //   _handlePlay(d);
      // }
    }
  }
}
