import 'package:flutter/material.dart';
import 'package:ludo/components/token.dart';

class Player {
  final List<Token> tokens;
  final Color playerColor;
  final String name;

  Player({
    @required this.playerColor,
    @required this.tokens,
    @required this.name,
  });

  bool get haveTokenInBase {
    for (Token t in tokens) {
      if (t.isInBase) return true;
    }
    return false;
  }

  bool get haveTokenOutBase {
    for (Token t in tokens) {
      if (!t.isInBase) return true;
    }
    return false;
  }

  String toString() => "${this.name}";
}
