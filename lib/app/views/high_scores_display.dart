import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo/app/shared/components/list_items_builder.dart';
import 'package:ludo/app/shared/models/score_register.dart';
import 'package:ludo/app/shared/repositories/database.dart';
import 'package:ludo/app/util/colors.dart';

class HighScoresDisplay extends StatefulWidget {
  final Database storage;

  const HighScoresDisplay({Key key, this.storage}) : super(key: key);

  @override
  _HighScoresDisplayState createState() => _HighScoresDisplayState();
}

class _HighScoresDisplayState extends State<HighScoresDisplay> {
  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pontuações',
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
                child: _buildContents(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<ScoreRegister>> _getData(
    BuildContext context,
  ) async {
    List<ScoreRegister> scores = List<ScoreRegister>();

    try {
      scores.addAll(await widget.storage.getScores());
    } on PlatformException catch (e) {
      throw PlatformException(
          code: 'error_get_courses_data', message: e.message);
    } catch (e) {
      print(e);
    }

    scores.sort((a, b) => a.score.compareTo(b.score));
    return scores.reversed.toList();
  }

  Widget _buildContents(BuildContext context) {
    if (isLoading)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Carregando ... ',
              style: TextStyle(
                color: AppColors.backgroundColor,
                fontSize: 16,
              ),
            )
          ],
        ),
      );

    return FutureBuilder<List<ScoreRegister>>(
      future: _getData(context),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(0),
          child: ListItemsBuilder(
            emptyTitle: 'Nada por aqui',
            emptyMessage: 'Você não tem pontuaçõs salvas',
            errorMessage: 'Tivemos um problema',
            snapshot: snapshot,
            itemBuilder: (context, score) => Card(
              child: ListTile(
                title: Text(score.name),
                subtitle: Text('${score.date}, (${score.gameMode})'),
                trailing: Text(score.score),
              ),
            ),
          ),
        );
      },
    );
  }
}
