// 节点数据类
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quick_dir_flutter/store/file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'tree.g.dart';
part 'tree.freezed.dart';




@unfreezed
class PathNode with _$PathNode {
  factory PathNode({
    required String label,
    String? path,
    Object? data,
    @Default(<PathNode>[]) List<PathNode> children,
    @Default(false) bool isExpanded,
  }) = _PathNode;

  factory PathNode.fromJson(Map<String, dynamic> json) =>
      _$PathNodeFromJson(json);
}

// 树形结构管理
@riverpod
class PathTree extends _$PathTree {
  final _expandedNodes = <String>{}; // 持久化展开状态

  @override
  List<PathNode> build() {
    final collections = ref.watch(pathConfigProvider);
    final query = ref.watch(searchQueryProvider).toLowerCase();

    // 生成树形结构
    return _buildTree(collections, query);
  }

  List<PathNode> _buildTree(List<PathCollection> collections, String query) {
  return collections.map((collection) {
    final collectionKey = 'collection_${collection.name}';

    // 生成组节点列表
    final groupNodes = collection.groups.map((group) {
      final groupKey = '${collectionKey}_group_${group.name}';

      // 生成路径节点列表
      final pathNodes = group.paths.map((path) {
        return PathNode(
          label: path.name,
          path: path.path,
          data: path,
        );
      }).toList();

      var groupNode = PathNode(
        label: group.name,
        data: group,
        isExpanded: _expandedNodes.contains(groupKey),
        children: pathNodes, // 直接传入子节点
      );

      return _matchesSearch(groupNode, query) ? groupNode : null;
    }).whereType<PathNode>().toList();

    // 创建集合节点并传入组节点作为子节点
    var collectionNode = PathNode(
      label: collection.name,
      data: collection,
      isExpanded: _expandedNodes.contains(collectionKey),
      children: groupNodes, // 直接传入子节点列表
    );

    return groupNodes.isNotEmpty ? collectionNode : null;
  }).whereType<PathNode>().toList();
}

  bool _matchesSearch(PathNode node, String query) {
    if (query.isEmpty) return true;

    // 递归检查节点及其子节点
    return node.label.toLowerCase().contains(query) ||
        node.children.any((child) => _matchesSearch(child, query));
  }

  // 切换节点展开状态
  void toggleNode(PathNode node) {
    final key = _getNodeKey(node);
    if (_expandedNodes.contains(key)) {
      _expandedNodes.remove(key);
    } else {
      _expandedNodes.add(key);
    }

    // 重建树结构
    state = _buildTree(ref.read(pathConfigProvider), ref.read(searchQueryProvider));
  }

  String _getNodeKey(PathNode node) {
    if (node.data is PathCollection) {
      return 'collection_${(node.data as PathCollection).name}';
    }
    if (node.data is PathGroup) {
      final group = node.data as PathGroup;
      return 'group_${group.name}';
    }
    return node.label;
  }
}

// UI组件部分
class PathTreeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(pathTreeProvider);

    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) => _TreeNode(nodes[index]),
    );
  }
}

class _TreeNode extends ConsumerWidget {
  final PathNode node;

  const _TreeNode(this.node);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (node.children.isEmpty) {
      return _PathItemTile(node);
    }

    return ExpansionTile(
      key: Key(_getNodeKey(node)),
      title: Text(node.label),
      initiallyExpanded: node.isExpanded,
      onExpansionChanged: (expanded) {
        ref.read(pathTreeProvider.notifier).toggleNode(node);
      },
      children: node.children.map((child) => _TreeNode(child)).toList(),
    );
  }

  String _getNodeKey(PathNode node) {
    if (node.data is PathCollection) return 'collection_${node.label}';
    if (node.data is PathGroup) return 'group_${node.label}';
    return 'path_${node.label}';
  }
}

class _PathItemTile extends StatelessWidget {
  final PathNode node;

  const _PathItemTile(this.node);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(node.label),
      subtitle: node.path != null ? Text(node.path!) : null,
      onTap: () => _handleTap(context),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showContextMenu(context),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (node.path != null) {
      // 处理路径打开逻辑
    }
  }

  void _showContextMenu(BuildContext context) {

  }
}
