import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_team/app/app.dart';
import 'package:e_team/app/app_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AppProviders(child: ETeamApp()));
}
