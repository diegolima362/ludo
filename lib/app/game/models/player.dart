import 'package:flutter/material.dart';
import 'package:ludo/app/game/components/token.dart';

class Player {
  final List<Token> tokens;
  final Color playerColor;
  final String name;
  final int id;
  final bool isHuman;

  int plays = 0;
  int time = 0;
  int enemiesHit = 0;
  int diceSum = 0;

  int get score {
    int finalScore = 0;

    finalScore += 1000 - plays;
    finalScore += 50 * enemiesHit;
    finalScore += diceSum;

    finalScore += 10 * time % 10;

    return finalScore;
  }

  Player({
    @required this.playerColor,
    @required this.tokens,
    @required this.isHuman,
    @required this.name,
    @required this.id,
  });

  bool get haveTokenInBase {
    for (Token t in tokens) {
      if (t.isInBase) return true;
    }
    return false;
  }

  bool get haveMovableToken {
    for (Token t in tokens) {
      if (!t.isInBase && !t.atCenter) return true;
    }
    return false;
  }

  Token get closerToken {
    Token token = tokens[0];
    int closerValue = 0;

    for (Token t in tokens) {
      if (t.currentStep >= closerValue) {
        token = t;
        closerValue = t.currentStep;
      }
    }
    return token;
  }

  String toString() => "$name";

  bool checkMovement(int steps) {
    bool canMove = false;

    tokens.forEach((t) {
      if (t.checkMove(steps)) canMove = true;
    });

    return canMove;
  }
}
