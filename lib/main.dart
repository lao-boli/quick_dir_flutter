// main.dart
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
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Manager',
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}
