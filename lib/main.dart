// main.dart
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quick_dir_flutter/page/home.dart';
import 'package:quick_dir_flutter/store/file.dart';



void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
      overrides: [
        pathConfigProvider.overrideWith(() => PathConfig()..load()),
      ],
    ),
  );
   doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Dir',
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      theme: ThemeData(primarySwatch: Colors.blue,fontFamily: Platform.isWindows ? 'HarmonyOS' : null),
      home: const MainScreen(),
    );
  }
}
