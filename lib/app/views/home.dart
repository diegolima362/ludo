import 'package:flutter/material.dart';
import 'package:ludo/app/game/game_mode.dart';
import 'package:ludo/app/game/ludo.dart';
import 'package:ludo/app/shared/components/menu_button.dart';
import 'package:ludo/app/shared/repositories/database.dart';
import 'package:ludo/app/util/colors.dart';
import 'package:ludo/app/views/high_scores_display.dart';

class HomePage extends StatefulWidget {
  final Database storage;

  const HomePage({Key key, this.storage}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _name = 'Jogador';
  GameMode _gameMode = GameMode.normal;
  bool _useTimeLimit = false;
  int _timeLimit = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ludo',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * .6,
            height: MediaQuery.of(context).size.height * .7,
            child: Card(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        cursorColor: AppColors.backgroundColor,
                        keyboardType: TextInputType.text,
                        maxLength: 50,
                        controller: TextEditingController(text: _name),
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          alignLabelWithHint: true,
                        ),
                        style: TextStyle(fontSize: 20.0),
                        maxLines: 1,
                        onChanged: (name) => _name = name,
                      ),
                      Text('Modo de Jogo'),
                      ListTile(
                        title: const Text('Normal Mode'),
                        leading: Radio(
                          activeColor: AppColors.backgroundColor,
                          value: GameMode.normal,
                          onChanged: (value) {
                            setState(() => _gameMode = value);
                          },
                          groupValue: _gameMode,
                        ),
                      ),
                      ListTile(
                        title: const Text('Fast Mode'),
                        leading: Radio(
                          activeColor: AppColors.backgroundColor,
                          value: GameMode.fast,
                          onChanged: (value) {
                            setState(() => _gameMode = value);
                          },
                          groupValue: _gameMode,
                        ),
                      ),
                      ListTile(
                        title: Text('Limitar tempo de jogada'),
                        trailing: Switch(
                          activeColor: AppColors.backgroundColor,
                          value: _useTimeLimit,
                          onChanged: (value) =>
                              setState(() => _useTimeLimit = value),
                        ),
                      ),
                      if (_useTimeLimit)
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLength: 50,
                          controller: TextEditingController(
                              text: _timeLimit.toString()),
                          decoration: InputDecoration(
                            labelText: 'Segundos',
                            alignLabelWithHint: true,
                          ),
                          style: TextStyle(fontSize: 20.0),
                          maxLines: 1,
                          onChanged: (value) => _timeLimit =
                              value.isEmpty ? 10 : int.tryParse(value),
                        ),
                      Expanded(child: SizedBox(height: 10)),
                      MenuButton(
                        text: 'Pontuações',
                        color: Colors.white,
                        textColor: AppColors.backgroundColor,
                        onPressed: () => _showScores(context),
                      ),
                      SizedBox(height: 10),
                      MenuButton(
                        text: 'Start',
                        color: AppColors.backgroundColor,
                        textColor: Colors.white,
                        onPressed: () => _start(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    final Ludo game = Ludo(
      context: context,
      storage: widget.storage,
      gameMode: _gameMode,
      playerName: _name,
      timeLimit: _timeLimit > 0 ? _timeLimit : 10,
      useTimeLimit: _useTimeLimit,
    );

    await game.initialize();

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return game.widget;
    }));
  }

  _showScores(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HighScoresDisplay(storage: widget.storage);
    }));
  }
}
