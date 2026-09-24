import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'pages/home_shell_android.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    StellarCenterApp(
      homeShellBuilder: ({
        required selectedTheme,
        required selectedStyle,
        required onThemeChanged,
        required onStyleChanged,
      }) {
        return HomeShellAndroid(
          selectedTheme: selectedTheme,
          selectedStyle: selectedStyle,
          onThemeChanged: onThemeChanged,
          onStyleChanged: onStyleChanged,
        );
      },
    ),
  );
}
