import 'package:flutter/material.dart';

import 'app.dart';
import 'platform/linux/home_shell_linux.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    StellarCenterApp(
      homeShellBuilder: ({
        required selectedTheme,
        required selectedStyle,
        required onThemeChanged,
        required onStyleChanged,
      }) {
        return LinuxHomeShell(
          selectedTheme: selectedTheme,
          selectedStyle: selectedStyle,
          onThemeChanged: onThemeChanged,
          onStyleChanged: onStyleChanged,
        );
      },
    ),
  );
}
