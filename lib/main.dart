import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ludo/app/shared/repositories/database.dart';

import 'app/util/colors.dart';
import 'app/views/views.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting("pt_BR", null);

  final flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);

  final _storage = HiveDatabase();

  runApp(
    MaterialApp(
      title: 'Ludo',
      theme:ThemeData(primarySwatch: AppColors.backgroundColor),
      home: HomePage(storage: _storage),
      color: AppColors.backgroundColor,
    ),
  );
}
