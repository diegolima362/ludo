import 'dart:async';

import 'package:hive/hive.dart';
import 'package:ludo/app/shared/models/score_register.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class BoxesName {
  static const SCORES_BOX = 'scores';
}

abstract class Database {
  Future<List<ScoreRegister>> getScores();

  void clearData();

  Future<void> addScore(ScoreRegister score);
}

String documentIdFromCurrentDate() =>
    (DateTime.now().millisecondsSinceEpoch / 6000).floor().toString();

class HiveDatabase implements Database {
  HiveDatabase() {
    _initDatabase();
  }

  List<ScoreRegister> _scores;

  Future<void> _initDatabase() async {
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();

    Hive.init(appDocumentDirectory.path);

    await Hive.openBox(BoxesName.SCORES_BOX);
  }

  @override
  Future<void> addScore(ScoreRegister score) async {
    final id = documentIdFromCurrentDate();
    print(score.toMap());
    print(id);
    await Hive.box(BoxesName.SCORES_BOX).put(id, score.toMap());
  }

  List<ScoreRegister> _buildScores(List<dynamic> data) {
    return data.map((e) => ScoreRegister.fromMap(e)).toList();
  }

  @override
  void clearData() {
    Hive.openBox(BoxesName.SCORES_BOX).then((box) => box.clear());
  }

  Future<void> clearBox(String boxName) async {
    await Hive.box(boxName).clear();
  }

  Future<void> closeDataBase() async {
    if (Hive.isBoxOpen(BoxesName.SCORES_BOX))
      await Hive.box(BoxesName.SCORES_BOX).close();
  }

  @override
  Future<List<ScoreRegister>> getScores() async {
    if (_scores == null) {
      final scoresMap = List<Map>();
      final box = await Hive.openBox(BoxesName.SCORES_BOX);
      box.toMap().forEach((key, value) => scoresMap.add(value));

      if (scoresMap.isNotEmpty) _scores = _buildScores(scoresMap);
    }

    return _scores;
  }
}
