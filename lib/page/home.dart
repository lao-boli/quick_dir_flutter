import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as Path;
import 'package:quick_dir_flutter/store/file.dart';
import 'package:quick_dir_flutter/util/log.dart';
import 'package:system_windows/system_windows.dart';

import '../store/tree.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final nodes = ref.watch(pathTreeProvider);

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
      body: ListView.builder(
        itemCount: nodes.length,
        itemBuilder: (context, index) =>
            buildTreeNode(ref, context, nodes[index]),
      ),
    );
  }

  Widget buildTreeNode(WidgetRef ref, BuildContext context, PathNode node) {
    if (node.children.isEmpty) {
      return buildPathItemTile(ref, context, node);
    }

    return ExpansionTile(
      key: Key(_getNodeKey(node)),
      title: Text(node.label),
      initiallyExpanded: node.isExpanded,
      onExpansionChanged: (expanded) {
        ref.read(pathTreeProvider.notifier).toggleNode(node);
      },
      children: node.children
          .map((child) => buildTreeNode(ref, context, child))
          .toList(),
    );
  }

  Widget buildPathItemTile(WidgetRef ref, BuildContext context, PathNode node) {
    Log.i(node);
    void handleTap() {
      if (node.path != null) {
        // 处理路径打开逻辑
        _openPath(ref, node.path!);
      }
    }

    void showContextMenu() {
      // 上下文菜单逻辑
    }
    void delete() {
      // ref.read(pathConfigProvider.notifier).deletePath(
      //     collectionIndex: collectionIndex,
      //     groupIndex: groupIndex,
      //     pathIndex: pathIndex)
    }

    return ListTile(
      title: Text(node.label),
      subtitle: node.path != null ? Text(node.path!) : null,
      onTap: handleTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => delete(),
      ),
    );
  }

// 保持相同的key生成逻辑
  String _getNodeKey(PathNode node) {
    if (node.data is PathCollection) return 'collection_${node.label}';
    if (node.data is PathGroup) return 'group_${node.label}';
    return 'path_${node.label}';
  }

  // Widget _buildPathList(WidgetRef ref) {final paths = ref.watch(filteredKeysProvider);return ListView.builder(itemCount: paths.length, itemBuilder: (context, index) {final key = paths[index];return ListTile(title: Text(key), subtitle: Text(ref.watch(pathConfigProvider)[key] ?? ''), onTap: () => _openPath(ref, key),);},);}
  //
  void _openPath(WidgetRef ref, String key) async {
    final path = key;
    Log.i(path);
    if (path == null) return;
    var systemWindows = SystemWindows();

    final activeApps = await systemWindows.getActiveApps();
    final titles = activeApps.map((e) => e.title).toList();

    if (titles.any((element) => containsPathInTitle(element, path))) {
      Process.run('D:\\projects\\IdeaProjects\\quick_dir\\windowutil.exe',
          ["window-to-top", path]).then((value) {
        if (value.exitCode != 0) {
          SmartDialog.showToast('窗口未找到');
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

  void _showAddDialog(WidgetRef ref) {
    // final nameController = TextEditingController();
    // final pathController = TextEditingController();
    //
    // showDialog(
    //   context: ref.context,
    //   builder: (context) => AlertDialog(
    //     title: const Text("Add New Path"),
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         TextField(
    //           controller: nameController,
    //           decoration: const InputDecoration(labelText: "Name"),
    //         ),
    //         Row(
    //           children: [
    //             Expanded(
    //               child: TextField(
    //                 controller: pathController,
    //                 decoration: const InputDecoration(labelText: "Path"),
    //                 readOnly: true,
    //               ),
    //             ),
    //             IconButton(
    //               icon: const Icon(Icons.folder_open),
    //               onPressed: () async {
    //                 final dir = await FilePicker.platform.getDirectoryPath();
    //                 if (dir != null) pathController.text = dir;
    //               },
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: const Text("Cancel"),
    //       ),
    //       ElevatedButton(
    //         onPressed: () {
    //           Log.i(
    //               "Adding path: ${nameController.text} -> ${pathController.text}");
    //           if (nameController.text.isNotEmpty &&
    //               pathController.text.isNotEmpty) {
    //             ref.read(pathConfigProvider.notifier).addPath(
    //                   nameController.text,
    //                   pathController.text,
    //                 );
    //             Navigator.pop(context);
    //           } else {
    //             SmartDialog.showToast("Please fill in all fields.");
    //           }
    //         },
    //         child: const Text("Add"),
    //       ),
    //     ],
    //   ),
    // );
  }

  void _showDeleteDialog(WidgetRef ref) {
    // String? selectedKey;
    //
    // showDialog(
    //   context: ref.context,
    //   builder: (context) => AlertDialog(
    //     title: const Text("Delete Path"),
    //     content: DropdownButtonFormField<String>(
    //       items: ref
    //           .read(filteredKeysProvider)
    //           .map((key) => DropdownMenuItem(value: key, child: Text(key)))
    //           .toList(),
    //       onChanged: (v) => selectedKey = v,
    //       decoration: const InputDecoration(labelText: "Select Path"),
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: const Text("Cancel"),
    //       ),
    //       ElevatedButton(
    //         onPressed: () {
    //           if (selectedKey != null) {
    //             ref.read(pathConfigProvider.notifier).deletePath(selectedKey!);
    //             Navigator.pop(context);
    //           }
    //         },
    //         child: const Text("Delete"),
    //       ),
    //     ],
    //   ),
    // );
  }
}
