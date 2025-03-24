import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
typedef NativeWindowProc = Uint32 Function(IntPtr hwnd, IntPtr lParam);
typedef DartWindowProc = int Function(int hwnd, int lParam);

// 数据模型
class PathConfig {
  Map<String, String> paths = {};

  PathConfig.fromJson(Map<String, dynamic> json) {
    paths = Map<String, String>.from(json['paths'] ?? {});
  }

  Map<String, dynamic> toJson() => {'paths': paths};
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final String configFile = 'path_manager.json';
  PathConfig config = PathConfig.fromJson({'paths': {}});
  List<String> filteredKeys = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
    searchController.addListener(_onSearchChanged);
  }

  // 加载配置
  Future<void> _loadConfig() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$configFile');
    if (await file.exists()) {
      final contents = await file.readAsString();
      setState(() {
        config = PathConfig.fromJson(json.decode(contents));
        filteredKeys = _getSortedKeys();
      });
    }
  }

  // 保存配置
  Future<void> _saveConfig() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$configFile');
    await file.writeAsString(json.encode(config.toJson()));
  }

  List<String> _getSortedKeys() {
    final keys = config.paths.keys.toList();
    keys.sort();
    return keys;
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredKeys = _getSortedKeys()
          .where((key) => key.toLowerCase().contains(query))
          .toList();
    });
  }

  // 添加路径对话框
  void _showAddDialog() {
    String name = '';
    String path = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Path"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Name"),
              onChanged: (v) => name = v,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: "Path"),
                    readOnly: true,
                    controller: TextEditingController(text: path),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.folder_open),
                  onPressed: () async {
                    final dir = await FilePicker.platform.getDirectoryPath();
                    if (dir != null) path = dir;
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty && path.isNotEmpty) {
                setState(() {
                  config.paths[name] = path;
                  _saveConfig();
                  filteredKeys = _getSortedKeys();
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  // 删除路径对话框
  void _showDeleteDialog() {
    String? selectedKey;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Path"),
        content: DropdownButtonFormField<String>(
          items: filteredKeys
              .map((key) => DropdownMenuItem(value: key, child: Text(key)))
              .toList(),
          onChanged: (v) => selectedKey = v,
          decoration: InputDecoration(labelText: "Select Path"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedKey != null) {
                setState(() {
                  config.paths.remove(selectedKey);
                  _saveConfig();
                  filteredKeys = _getSortedKeys();
                });
                Navigator.pop(context);
              }
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  // 打开路径
  void _openPath(String path) async {
    if (_activateExplorerWindow(path)) return;

    final dir = Directory(path);
    if (await dir.exists()) {
      Process.run('explorer', [dir.absolute.path]);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Path does not exist"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // 使用Win32 API检测并激活窗口
  bool _activateExplorerWindow(String path) {
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
      free(ptr);
    }
    return false;
  }

  static int _enumWindowsProc(int hwnd, int lParam) {
    final className = wsalloc(256);
    GetClassName(hwnd, className, 256);

    if (className.toDartString() == 'CabinetWClass') {
      final title = wsalloc(256);
      GetWindowText(hwnd, title, 256);

      // 获取传入的路径参数
      final pathPtr = Pointer<Utf16>.fromAddress(lParam);
      final targetPath = pathPtr.toDartString();

      if (title.toDartString().contains(targetPath)) {
        final pHwnd = Pointer<IntPtr>.fromAddress(lParam);
        pHwnd.value = hwnd;
        free(title);
        free(className);
        return 0; // 停止枚举
      }
      free(title);
    }
    free(className);
    return 1; // 继续枚举
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredKeys.length,
        itemBuilder: (context, index) {
          final key = filteredKeys[index];
          return ListTile(
            title: Text(key),
            subtitle: Text(config.paths[key] ?? ''),
            onTap: () => _openPath(config.paths[key]!),
          );
        },
      ),
    );
  }
}
