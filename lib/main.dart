// main.dart
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quick_dir_flutter/util/log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';

part 'main.g.dart'; // 生成的代码文件

typedef NativeWindowProc = Uint32 Function(IntPtr hwnd, IntPtr lParam);
typedef DartWindowProc = int Function(int hwnd, int lParam);

// 数据模型
@riverpod
class PathConfig extends _$PathConfig {
  @override
  Map<String, String> build() => {};

  Future<void> load() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/path_manager.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      state = Map<String, String>.from(json.decode(contents)['paths'] ?? {});
    }
  }

  Future<void> _save() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/path_manager.json');
    await file.writeAsString(json.encode({'paths': state}));
  }

  void addPath(String name, String path) {
    state = {...state, name: path};
    _save();
  }

  void deletePath(String name) {
    state = {...state..remove(name)};
    _save();
  }
}

// 搜索功能
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

// 过滤后的键列表
@riverpod
List<String> filteredKeys(FilteredKeysRef ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final keys = ref.watch(pathConfigProvider.select((value) => value.keys.toList()));
  keys.sort();
  return keys.where((key) => key.toLowerCase().contains(query)).toList();
}

// 窗口管理器
@Riverpod(keepAlive: true)
WindowManager windowManager(WindowManagerRef ref) => WindowManager();

class WindowManager {
  bool activateExplorerWindow(String path) {
    final ptr = calloc<IntPtr>();
    final pathPtr = path.toNativeUtf16();

    try {
      EnumWindows(
        Pointer.fromFunction<NativeWindowProc>(_enumWindowsProc, 0),
        pathPtr.address,
      );

      final hwnd = ptr.value;
      if (hwnd != 0) {
        ShowWindow(hwnd, SW_RESTORE);
        SetForegroundWindow(hwnd);
        return true;
      }
    } finally {
      free(pathPtr);
      calloc.free(ptr);
    }
    return false;
  }

  static int _enumWindowsProc(int hwnd, int lParam) {
    final className = wsalloc(256);
    GetClassName(hwnd, className, 256);

    if (className.toDartString() == 'CabinetWClass') {
      final title = wsalloc(256);
      GetWindowText(hwnd, title, 256);

      final pathPtr = Pointer<Utf16>.fromAddress(lParam);
      final targetPath = pathPtr.toDartString();

      if (title.toDartString().contains(targetPath)) {
        final pHwnd = Pointer<IntPtr>.fromAddress(lParam);
        pHwnd.value = hwnd;
        free(title);
        free(className);
        return 0;
      }
      free(title);
    }
    free(className);
    return 1;
  }
}

void main() => runApp(
  ProviderScope(
    child: MyApp(),
    overrides: [
      pathConfigProvider.overrideWith(() => PathConfig()..load()),
    ],
  ),
);

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

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
          ),
          onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).updateQuery(value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(ref),
          ),
        ],
      ),
      body: _buildPathList(ref),
    );
  }

  Widget _buildPathList(WidgetRef ref) {
    final paths = ref.watch(filteredKeysProvider);

    return ListView.builder(
      itemCount: paths.length,
      itemBuilder: (context, index) {
        final key = paths[index];
        return ListTile(
          title: Text(key),
          subtitle: Text(ref.watch(pathConfigProvider)[key] ?? ''),
          onTap: () => _openPath(ref, key),
        );
      },
    );
  }

  void _openPath(WidgetRef ref, String key) {
    final path = ref.read(pathConfigProvider)[key];
    if (path == null) return;

    final windowManager = ref.read(windowManagerProvider);
    if (!windowManager.activateExplorerWindow(path)) {
      Process.run('explorer', [path]);
    }
  }

  void _showAddDialog(WidgetRef ref) {
    final nameController = TextEditingController();
    final pathController = TextEditingController();

    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Path"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pathController,
                    decoration: const InputDecoration(labelText: "Path"),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () async {
                    final dir = await FilePicker.platform.getDirectoryPath();
                    if (dir != null) pathController.text = dir;
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Log.i( "Adding path: ${nameController.text} -> ${pathController.text}");
              if (nameController.text.isNotEmpty &&
                  pathController.text.isNotEmpty) {
                ref.read(pathConfigProvider.notifier).addPath(
                  nameController.text,
                  pathController.text,
                );
                Navigator.pop(context);
              } else {
                SmartDialog.showToast("Please fill in all fields.");
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(WidgetRef ref) {
    String? selectedKey;

    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Path"),
        content: DropdownButtonFormField<String>(
          items: ref.read(filteredKeysProvider).map((key) =>
            DropdownMenuItem(value: key, child: Text(key))).toList(),
          onChanged: (v) => selectedKey = v,
          decoration: const InputDecoration(labelText: "Select Path"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedKey != null) {
                ref.read(pathConfigProvider.notifier).deletePath(selectedKey!);
                Navigator.pop(context);
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
