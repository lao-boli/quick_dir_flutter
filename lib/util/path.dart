import 'dart:io';

import 'package:system_windows/system_windows.dart';

import 'package:path/path.dart' as Path;

import 'log.dart';

void openPath(String key) async {
  final path = key;
  Log.i(path);
  if (path == null) return;
  var systemWindows = SystemWindows();

  final activeApps = await systemWindows.getActiveApps();
  final titles = activeApps.map((e) => e.title).toList();

  if (titles.any((element) => containsPathInTitle(element, path))) {
    Process.run('windowutil.exe',
        ["window-to-top", path]).then((value) {
      if (value.exitCode != 0) {
        // SmartDialog.showToast('窗口未找到');
      }
      return null;
    });
    return;
  } else {
    Process.run('explorer', [path]);
  }
}

bool containsPathInTitle(String title, String path) {
  // 尝试匹配不同格式的路径显示
  String normalizedPath = Path.normalize(path);
  List<String> possibleFormats = [
    normalizedPath,
    Path.basename(normalizedPath),
    '$normalizedPath - 文件资源管理器',
  ];

  for (String format in possibleFormats) {
    if (title == format || title == '$format - 文件资源管理器') {
      return true;
    }
  }
  return false;
}
