import 'dart:io';

import 'package:animated_tree_view/node/indexed_node.dart';
import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as Path;
import 'package:quick_dir_flutter/store/file.dart';
import 'package:quick_dir_flutter/util/icon_util.dart';
import 'package:quick_dir_flutter/util/log.dart';
import 'package:quick_dir_flutter/util/path.dart';
import 'package:system_windows/system_windows.dart';

import '../components/windowBar.dart';
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
    // final currentCollection = ref.watch(currentCollectionProvider);
    final currentCollection = ref.watch(filteredCollectionProvider);
    final filteredGroups = currentCollection?.groups ?? [];
    ref.listen<List<PathCollection>>(pathConfigProvider, (_, collections) {
      if (collections.isNotEmpty && currentCollection == null) {
        // 使用postFrameCallback避免build过程中修改状态
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(currentCollectionProvider.notifier)
              .setCurrentCollection(collections.first);
        });
      }
    });

    return Scaffold(
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WindowTitleBarBox(
            child: Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  const WindowButtons(), // 原外层AppBar的窗口按钮
                ],
              ),
            ),
          ),

          // 原内层AppBar的内容
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // 集合操作按钮
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () =>
                      _showUpdateCollectionDialog(ref, currentCollection!),
                ),

                // 集合选择下拉框
                SizedBox(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentCollection?.id,
                      hint: const Text('选择集合'),
                      items: ref.watch(pathConfigProvider).map((collection) {
                        return DropdownMenuItem(
                          value: collection.id,
                          child: Text(collection.name),
                        );
                      }).toList(),
                      onChanged: (id) => ref
                          .read(currentCollectionProvider.notifier)
                          .setCurrentCollectionById(id!),
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
                      ),
                      onChanged: (value) =>
                          ref.read(searchTermProvider.notifier).state = value,
                    ),
                  ),
                ),

                // 操作按钮组
                IconButton(
                  icon: getIcon('collection'),
                  onPressed: () => _showAddCollectionDialog(ref),
                ),
                IconButton(
                  icon: const Icon(Icons.group_add),
                  onPressed: () => _showAddGroupDialog(ref),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddDialog(ref),
                ),
              ],
            ),
          ),

          filteredGroups.isEmpty
              ? const Expanded(child: Center(child: Text("暂无组")))
              // : SizedBox(height: MediaQuery.of(context).size.height - 120, child: PathTree()),
              : const Expanded(child: PathTree()),
        ],
      ),
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
    showDialog(
      context: ref.context,
      builder: (context) {
        return HookConsumer(
          builder: (context, ref, _) {
            final collections = ref.watch(pathConfigProvider);
            final currentCollection = ref.watch(currentCollectionProvider);
            final groupNameController = useTextEditingController();
            var selectedCollectionId =
                useState<String?>(currentCollection?.id); // 用于存储选中的集合ID

            return AlertDialog(
              title: const Text("添加组"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 集合选择下拉框
                  DropdownButtonFormField<String?>(
                    value: selectedCollectionId.value,
                    hint: const Text("选择集合"),
                    items: collections.map((collection) {
                      return DropdownMenuItem(
                        value: collection.id,
                        child: Text(collection.name),
                      );
                    }).toList(),
                    onChanged: (newCollectionId) {
                      selectedCollectionId.value = newCollectionId;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 组名称输入
                  TextField(
                    controller: groupNameController,
                    decoration: const InputDecoration(
                      labelText: "组名",
                      hintText: "输入组名",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("取消"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 验证输入有效性
                    if (selectedCollectionId.value == null ||
                        selectedCollectionId.value == '' ||
                        groupNameController.text.isEmpty) {
                      SmartDialog.showToast("请输入有效的集合和组名");
                      return;
                    }

                    // 调用添加组方法
                    ref.read(pathConfigProvider.notifier).addGroup(
                          selectedCollectionId.value!,
                          groupNameController.text,
                        );

                    Navigator.pop(context);
                  },
                  child: const Text("添加"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCollectionDialog(WidgetRef ref) {
    showDialog(
      context: ref.context,
      builder: (context) {
        return HookConsumer(
          builder: (context, ref, _) {
            final collectionNameController = useTextEditingController();

            return AlertDialog(
              title: const Text("添加集合"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: collectionNameController,
                    decoration: const InputDecoration(
                      labelText: "集合名称",
                      hintText: "输入集合名称",
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("取消"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 验证输入有效性
                    if (collectionNameController.text.isEmpty) {
                      SmartDialog.showToast("集合名称不能为空");
                      return;
                    }

                    // 调用添加集合方法
                    ref.read(pathConfigProvider.notifier).addCollection(
                          collectionNameController.text,
                        );

                    // 关闭对话框并清空输入
                    collectionNameController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("确认添加"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateCollectionDialog(WidgetRef ref, PathCollection collection) {
    showDialog(
      context: ref.context,
      builder: (context) {
        return HookConsumer(
          builder: (context, ref, _) {
            final collectionNameController = useTextEditingController();
            collectionNameController.text = collection.name;

            return AlertDialog(
              title: const Text("修改集合"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: collectionNameController,
                    decoration: const InputDecoration(
                      labelText: "集合名称",
                      hintText: "输入集合名称",
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("取消"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 验证输入有效性
                    if (collectionNameController.text.isEmpty) {
                      SmartDialog.showToast("集合名称不能为空");
                      return;
                    }

                    // 调用添加集合方法
                    ref.read(pathConfigProvider.notifier).updateCollection(
                          collection.id,
                          collectionNameController.text,
                        );

                    // 关闭对话框并清空输入
                    collectionNameController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("确认修改"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDialog(WidgetRef ref) {
    showDialog(
      context: ref.context,
      builder: (context) => HookConsumer(
        builder: (context, ref, child) {
          // 文本控制器
          final nameController = useTextEditingController();
          final pathController = useTextEditingController();

          // 局部状态管理
          final selectedCollectionId = useState<String?>(null);
          final selectedGroupId = useState<String?>(null);

          // 获取集合数据（假设pathConfigProvider是全局状态）
          final collections = ref.watch(pathConfigProvider);

          return AlertDialog(
            title: const Text("添加路径"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 集合选择下拉框
                DropdownButtonFormField<String?>(
                  value: selectedCollectionId.value,
                  hint: const Text("选择集合"),
                  items: collections.map((collection) {
                    return DropdownMenuItem(
                      value: collection.id,
                      child: Text(collection.name),
                    );
                  }).toList(),
                  onChanged: (collectionId) {
                    selectedCollectionId.value = collectionId;
                    selectedGroupId.value = null; // 重置组选择
                  },
                ),
                const SizedBox(height: 16),

                // 组选择下拉框
                DropdownButtonFormField<String?>(
                  value: selectedGroupId.value,
                  hint: const Text("选择组"),
                  items: collections
                      .firstWhere(
                        (c) => c.id == selectedCollectionId.value,
                        orElse: () =>
                            PathCollection(id: '', name: '', groups: []),
                      )
                      .groups
                      .map((group) => DropdownMenuItem(
                            value: group.id,
                            child: Text(group.name),
                          ))
                      .toList(),
                  onChanged: selectedCollectionId.value != null
                      ? (groupId) => selectedGroupId.value = groupId
                      : null,
                ),
                const SizedBox(height: 16),

                // 路径名称输入
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "路径名称"),
                ),
                const SizedBox(height: 16),

                // 路径选择
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: pathController,
                        decoration: const InputDecoration(labelText: "路径"),
                        // readOnly: true,
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
                child: const Text("取消"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      pathController.text.isEmpty ||
                      selectedCollectionId.value == null ||
                      selectedGroupId.value == null) {
                    SmartDialog.showToast("请填写完整信息");
                    return;
                  }

                  ref.read(pathConfigProvider.notifier).addPath(
                        collectionId: selectedCollectionId.value!,
                        groupId: selectedGroupId.value!,
                        name: nameController.text,
                        path: pathController.text,
                      );
                  Navigator.pop(context);
                },
                child: const Text("添加"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PathTree extends HookConsumerWidget {
  const PathTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathConfig = ref.watch(pathConfigProvider);
    Log.w('rebuild');
    // final currentCollection = ref.watch(currentCollectionProvider);
    final currentCollection = ref.watch(filteredCollectionProvider);
    final root = TreeNode.root();
    final nodes = currentCollection?.groups.map((group) {
      Log.i(group);
      return TreeNode(
        key: group.id,
        data: group,
      )..addAll(
          group.paths
              .map(
                (item) => TreeNode(key: item.id, data: item),
              )
              .toList(),
        );
    }).toList();
    root.addAll(nodes ?? []);
    final treeViewKey = Key(currentCollection?.id ?? 'default_tree_key');
    // Log.i(root);

    return TreeView.simple(
      key: treeViewKey,
      onTreeReady: (controller) {
        Log.i('ready');
        controller.expandAllChildren(root);
      },
      tree: root,
      showRootNode: false,
      expansionBehavior: ExpansionBehavior.none,
      builder: (context, node) {
        // Log.i(node.childrenAsList);
        if (node.data is PathGroup) {
          final group = node.data as PathGroup;
          return _GroupTile(
              group: node.data as PathGroup,
              node: node,
              onMore: () {
                _showUpdateGroupDialog(ref, group);
              },
              onDelete: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: const Text("删除组"),
                          content: const Text(
                              "确定删除该组？"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("取消"),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(pathConfigProvider.notifier).deleteById(node.data.id);
                                Navigator.pop(context);
                              },
                              child: const Text("删除"),
                            )
                          ]);
                    });
              });
        }
        if (node.data is PathItem) {
          final item = node.data as PathItem;
          return _PathTile(
            item: node.data as PathItem,
            onTap: () => openPath(item.path),
            onMore: () {
              _showUpdateUpdateDialog(ref, item);
            },
            onDelete: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        title: const Text("删除路径"),
                        content: const Text(
                            "确定删除该路径？"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("取消"),
                          ),
                          TextButton(
                            onPressed: () {
                              // ref.read(pathConfigProvider.notifier).deleteById(node.data.id);
                              ref.read(pathConfigProvider.notifier).deleteById(node.data.id);
                              Navigator.pop(context);
                            },
                            child: const Text("删除"),
                          )
                        ]);
                  });
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showUpdateGroupDialog(WidgetRef ref, PathGroup group) {
    showDialog(
      context: ref.context,
      builder: (context) {
        return HookConsumer(
          builder: (context, ref, _) {
            final groupNameController = useTextEditingController();
            groupNameController.text = group.name;
            final collectionId = group.collectionId;

            return AlertDialog(
              title: const Text("修改组"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: groupNameController,
                    decoration: const InputDecoration(
                      labelText: "组名称",
                      hintText: "输入组名称",
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("取消"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 验证输入有效性
                    if (groupNameController.text.isEmpty) {
                      SmartDialog.showToast("集合名称不能为空");
                      return;
                    }

                    // 调用添加集合方法
                    ref.read(pathConfigProvider.notifier).updateGroupName(
                          collectionId,
                          group.id,
                          groupNameController.text,
                        );

                    // 关闭对话框并清空输入
                    groupNameController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("确认修改"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateUpdateDialog(WidgetRef ref, PathItem item) {
    showDialog(
      context: ref.context,
      builder: (context) => HookConsumer(
        builder: (context, ref, child) {
          // 文本控制器
          final nameController = useTextEditingController();
          nameController.text = item.name;
          final pathController = useTextEditingController();
          pathController.text = item.path;

          // 局部状态管理
          final selectedCollectionId = useState<String?>(null);
          final selectedGroupId = useState<String?>(null);

          // 获取集合数据（假设pathConfigProvider是全局状态）
          final collections = ref.watch(pathConfigProvider);

          return AlertDialog(
            title: const Text("修改路径"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // // 集合选择下拉框
                // DropdownButtonFormField<String?>(
                //   value: selectedCollectionId.value,
                //   hint: const Text("选择集合"),
                //   items: collections.map((collection) {
                //     return DropdownMenuItem(
                //       value: collection.id,
                //       child: Text(collection.name),
                //     );
                //   }).toList(),
                //   onChanged: (collectionId) {
                //     selectedCollectionId.value = collectionId;
                //     selectedGroupId.value = null; // 重置组选择
                //   },
                // ),
                // const SizedBox(height: 16),
                // // 组选择下拉框
                // DropdownButtonFormField<String?>(
                //   value: selectedGroupId.value,
                //   hint: const Text("选择组"),
                //   items: collections
                //       .firstWhere(
                //         (c) => c.id == selectedCollectionId.value,
                //     orElse: () =>
                //         PathCollection(id: '', name: '', groups: []),
                //   )
                //       .groups
                //       .map((group) => DropdownMenuItem(
                //     value: group.id,
                //     child: Text(group.name),
                //   ))
                //       .toList(),
                //   onChanged: selectedCollectionId.value != null
                //       ? (groupId) => selectedGroupId.value = groupId
                //       : null,
                // ),
                // const SizedBox(height: 16),

                // 路径名称输入
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "路径名称"),
                ),
                const SizedBox(height: 16),

                // 路径选择
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: pathController,
                        decoration: const InputDecoration(labelText: "路径"),
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
                child: const Text("取消"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      pathController.text.isEmpty) {
                    SmartDialog.showToast("请填写完整信息");
                    return;
                  }

                  ref.read(pathConfigProvider.notifier).updatePath(
                        collectionId: item.collectionId,
                        groupId: item.groupId,
                        pathId: item.id,
                        name: nameController.text,
                        path: pathController.text,
                      );
                  Navigator.pop(context);
                },
                child: const Text("修改"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final PathGroup group;
  final TreeNode node;
  final VoidCallback onDelete;
  final VoidCallback onMore;

  const _GroupTile({
    required this.group,
    required this.node,
    required this.onDelete,
    required this.onMore,
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
            icon: const Icon(Icons.more_horiz),
            onPressed: onMore,
          ),
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
  final VoidCallback onMore;

  const _PathTile({
    required this.item,
    required this.onDelete,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(item.name),
      subtitle: Text(item.path),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: onMore,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
