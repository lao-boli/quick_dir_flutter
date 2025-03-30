import 'dart:io';

import 'package:animated_tree_view/node/indexed_node.dart';
import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as Path;
import 'package:quick_dir_flutter/store/file.dart';
import 'package:quick_dir_flutter/util/log.dart';
import 'package:quick_dir_flutter/util/path.dart';
import 'package:system_windows/system_windows.dart';

import '../store/tree.dart';

final mainSelectedCollectionIdProvider = StateProvider<String?>((ref) => null);
final selectedCollectionIdProvider = StateProvider<String?>((ref) => null);
final selectedGroupIdProvider = StateProvider<String?>((ref) => null);
final selectedCollectionProvider =
    StateProvider<PathCollection?>((ref) => null);
// final selectedCollectionIdProvider =
// StateProvider<String?>((ref) => null);

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final paths = ref.watch(pathConfigProvider);
    final nodes = ref.watch(pathTreeProvider);
    final selectedCollection = ref.watch(selectedCollectionProvider);
    final selectedCollectionId = ref.watch(mainSelectedCollectionIdProvider);
    final filteredGroups = selectedCollection?.groups ?? [];
    ref.listen<List<PathCollection>>(pathConfigProvider, (_, collections) {
      if (collections.isNotEmpty &&
          ref.read(selectedCollectionProvider) == null) {
        // 使用postFrameCallback避免build过程中修改状态
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(selectedCollectionProvider.notifier).state =
              collections.first;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // 集合选择下拉框
            Flexible(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: ref.watch(selectedCollectionIdProvider),
                  hint: const Text('选择集合', style: TextStyle()),
                  items: ref.watch(pathConfigProvider).map((collection) {
                    return DropdownMenuItem(
                      value: collection.id,
                      child: Text(
                        collection.name,
                        style: const TextStyle(),
                      ),
                    );
                  }).toList(),
                  onChanged: (collection) {
                    ref.read(selectedCollectionIdProvider.notifier).state =
                        collection;
                  },
                ),
              ),
            ),
            // 搜索框
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "搜索...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).updateQuery(value),
                ),
              ),
            ),
          ],
        ),
        // title: TextField(
        //   controller: searchController,
        //   decoration: const InputDecoration(
        //     hintText: "Search...",
        //     border: InputBorder.none,
        //   ),
        //   onChanged: (value) =>
        //       ref.read(searchQueryProvider.notifier).updateQuery(value),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => _showAddGroupDialog(ref),
          ),
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
      body: filteredGroups.isEmpty
          ? const Center(child: Text("请先选择集合"))
          : const PathTree(),
    );
  }

  Widget buildTreeView(WidgetRef ref, BuildContext context, PathNode node) {
    TreeView.indexed(
        tree: IndexedTreeNode.root(),
        builder: (context, node) {
          // build your node item here
          // return any widget that you need
          return ListTile(
            title: Text("Item ${node.level}-${node.key}"),
            subtitle: Text('Level ${node.level}'),
          );
        });

    return Container();
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
      if (node.data == null) {
        SmartDialog.showToast('Cannot delete node with null data');
      }

      if (node.data is! PathItem) {
        SmartDialog.showToast('Invalid data type for deletion. '
            'Expected: PathItem, Actual: ${node.data.runtimeType}');
      }
      final item = node.data as PathItem;
      ref.read(pathConfigProvider.notifier).deleteItem(
            item.id,
          );
    }

    void showDeleteDialog() {
      // 删除逻辑
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text("Delete Path"),
                content:
                    const Text("Are you sure you want to delete this path?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      delete();
                      Navigator.pop(context);
                    },
                    child: const Text("Delete"),
                  )
                ]);
          });
    }

    return ListTile(
      title: Text(node.label),
      subtitle: node.path != null ? Text(node.path!) : null,
      onTap: handleTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => showDeleteDialog(),
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

  void _showAddGroupDialog(WidgetRef ref) {
    final groupNameController = TextEditingController();
    String? selectedCollectionId; // 用于存储选中的集合ID

    showDialog(
      context: ref.context,
      builder: (context) {
        final collections = ref.watch(pathConfigProvider);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Group"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 集合选择下拉框
                  DropdownButtonFormField<String?>(
                    value: selectedCollectionId,
                    hint: const Text("Select Collection"),
                    items: collections.map((collection) {
                      return DropdownMenuItem(
                        value: collection.id,
                        child: Text(collection.name),
                      );
                    }).toList(),
                    onChanged: (newCollectionId) {
                      setState(() {
                        selectedCollectionId = newCollectionId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 组名称输入
                  TextField(
                    controller: groupNameController,
                    decoration: const InputDecoration(
                      labelText: "Group Name",
                      hintText: "Enter group name",
                    ),
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
                    // 验证输入有效性
                    if (selectedCollectionId == null ||
                        groupNameController.text.isEmpty) {
                      SmartDialog.showToast(
                          "Please select a collection and enter a group name");
                      return;
                    }

                    // 调用添加组方法
                    ref.read(pathConfigProvider.notifier).addGroup(
                          selectedCollectionId!,
                          groupNameController.text,
                        );

                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDialog(WidgetRef ref) {
    final nameController = TextEditingController();
    final pathController = TextEditingController();

    // 重置选择状态
    ref.read(selectedCollectionIdProvider.notifier).state = null;
    ref.read(selectedGroupIdProvider.notifier).state = null;

    showDialog(
      context: ref.context,
      builder: (context) {
        final collections = ref.watch(pathConfigProvider);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Path"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 集合选择下拉框
                  DropdownButtonFormField<String?>(
                    value: ref.watch(selectedCollectionIdProvider),
                    hint: const Text("Select Collection"),
                    items: collections.map((collection) {
                      return DropdownMenuItem(
                        value: collection.id,
                        child: Text(collection.name),
                      );
                    }).toList(),
                    onChanged: (collectionId) {
                      ref.read(selectedCollectionIdProvider.notifier).state =
                          collectionId;
                      ref.read(selectedGroupIdProvider.notifier).state = null;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  // 组选择下拉框
                  DropdownButtonFormField<String?>(
                    value: ref.watch(selectedGroupIdProvider),
                    hint: const Text("Select Group"),
                    items: collections
                        .firstWhere(
                          (c) {
                            Log.i(c.id);
                            var watch = ref.watch(selectedCollectionIdProvider);
                            Log.i(watch);
                            return c.id == watch;
                          },
                          orElse: () => PathCollection(id: '', name: ''),
                        )
                        .groups
                        .map((group) {
                          return DropdownMenuItem(
                            value: group.id,
                            child: Text(group.name),
                          );
                        })
                        .toList(),
                    onChanged: ref.watch(selectedCollectionIdProvider) != null
                        ? (groupId) {
                            ref.read(selectedGroupIdProvider.notifier).state =
                                groupId;
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // 路径名称输入
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  const SizedBox(height: 16),

                  // 路径选择
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
                          final dir =
                              await FilePicker.platform.getDirectoryPath();
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
                    final collectionId = ref.read(selectedCollectionIdProvider);
                    final groupId = ref.read(selectedGroupIdProvider);

                    if (nameController.text.isEmpty ||
                        pathController.text.isEmpty ||
                        collectionId == null ||
                        groupId == null) {
                      SmartDialog.showToast("Please fill in all fields.");
                      return;
                    }

                    ref.read(pathConfigProvider.notifier).addPath(
                          collectionId: collectionId,
                          groupId: groupId,
                          name: nameController.text,
                          path: pathController.text,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(WidgetRef ref) {}
}

class PathTree extends HookConsumerWidget {
  const PathTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathConfig = ref.watch(pathConfigProvider);
    final root = TreeNode.root();
    final nodes = pathConfig.expand((collection) => collection.groups).map((group) {
      Log.i(group);
        return TreeNode(
          key: group.id,
          data: group,
        )..addAll(group.paths
            .map((item) => TreeNode(
                  key: item.id,
                  data: item,
                ))
            .toList());
      }).toList();
    root.addAll(nodes);
    // Log.i(root);


    return TreeView.simple(
      tree: root,
      showRootNode: false,
      expansionBehavior: ExpansionBehavior.collapseOthers,
      builder: (context, node) {
        // Log.i(node.childrenAsList);
        if (node.data is PathGroup) {
          return _GroupTile(
            group: node.data as PathGroup,
            node: node,
            onDelete: () =>
                ref.read(pathConfigProvider.notifier).deleteById(node.data.id),
          );
        }
        if (node.data is PathItem) {
          final item = node.data as PathItem;
          return _PathTile(
            item: node.data as PathItem,
            onTap:() => openPath(item.path),
            onDelete: () =>
                ref.read(pathConfigProvider.notifier).deleteById(node.data.id),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _GroupTile extends StatelessWidget {
  final PathGroup group;
  final TreeNode node;
  final VoidCallback onDelete;

  const _GroupTile({
    required this.group,
    required this.node,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.group),
      title: Text(group.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  final PathItem item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _PathTile({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(item.name),
      subtitle: Text(item.path),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
