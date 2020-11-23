class ScoreRegister {
  final String name;
  final String date;
  final String score;
  final String gameMode;

  ScoreRegister({this.name, this.date, this.score, this.gameMode});

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'date': this.date,
      'score': this.score,
      'gameMode': this.gameMode,
    };
  }

  factory ScoreRegister.fromMap(Map<dynamic, dynamic> map) {
    return ScoreRegister(
      name: map['name'],
      date: map['date'],
      score: map['score'],
      gameMode: map['gameMode'],
    );
  }

  @override
  String toString() => '$name, $date, $score $gameMode';
}
