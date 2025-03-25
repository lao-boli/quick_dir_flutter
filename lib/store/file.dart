import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'file.g.dart';

// 基本路径对象
class PathItem {
  final String name;
  final String path;

  PathItem({required this.name, required this.path});

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
  };

  factory PathItem.fromJson(Map<String, dynamic> json) => PathItem(
    name: json['name'],
    path: json['path'],
  );
}

// 路径组
class PathGroup {
  final String name;
  final List<PathItem> paths;

  PathGroup({required this.name, this.paths = const []});

  Map<String, dynamic> toJson() => {
    'name': name,
    'paths': paths.map((p) => p.toJson()).toList(),
  };

  factory PathGroup.fromJson(Map<String, dynamic> json) => PathGroup(
    name: json['name'],
    paths: (json['paths'] as List)
        .map((p) => PathItem.fromJson(p))
        .toList(),
  );
}

// 集合（包含多个组）
class PathCollection {
  final String name;
  final List<PathGroup> groups;

  PathCollection({required this.name, this.groups = const []});

  Map<String, dynamic> toJson() => {
    'name': name,
    'groups': groups.map((g) => g.toJson()).toList(),
  };

  factory PathCollection.fromJson(Map<String, dynamic> json) => PathCollection(
    name: json['name'],
    groups: (json['groups'] as List)
        .map((g) => PathGroup.fromJson(g))
        .toList(),
  );
}

@riverpod
class PathConfig extends _$PathConfig {
  @override
  List<PathCollection> build() => [];

  Future<void> load() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/path_manager.json');

    if (await file.exists()) {
      final contents = await file.readAsString();
      final jsonData = json.decode(contents);

      // 处理旧版本数据迁移
      if (jsonData['paths'] != null) {
        // 旧格式转换为新格式：创建默认集合和组
        final legacyMap = Map<String, String>.from(jsonData['paths']);
        final defaultGroup = PathGroup(
          name: 'Default Group',
          paths: legacyMap.entries
              .map((e) => PathItem(name: e.key, path: e.value))
              .toList(),
        );
        state = [
          PathCollection(
            name: 'Default Collection',
            groups: [defaultGroup],
          )
        ];
        await _save();
      } else {
        // 新格式数据
        state = (jsonData['collections'] as List)
            .map((c) => PathCollection.fromJson(c))
            .toList();
      }
    }
  }

  Future<void> _save() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/path_manager.json');
    await file.writeAsString(json.encode({
      'collections': state.map((c) => c.toJson()).toList(),
    }));
  }

  // 添加集合
  void addCollection(String name) {
    state = [...state, PathCollection(name: name)];
    _save();
  }

  // 删除集合
  void deleteCollection(int collectionIndex) {
    state = [...state]..removeAt(collectionIndex);
    _save();
  }

  // 添加组到集合
  void addGroup(int collectionIndex, String groupName) {
    final updated = state[collectionIndex].groups.toList();
    updated.add(PathGroup(name: groupName));
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == collectionIndex)
          state[i].copyWith(groups: updated)
        else
          state[i]
    ];
    _save();
  }

  // 添加路径到指定集合的组
  void addPath({
    required int collectionIndex,
    required int groupIndex,
    required String name,
    required String path,
  }) {
    final collection = state[collectionIndex];
    final group = collection.groups[groupIndex];
    final updatedPaths = group.paths.toList()..add(PathItem(name: name, path: path));

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == collectionIndex)
          collection.copyWith(
            groups: [
              for (int j = 0; j < collection.groups.length; j++)
                if (j == groupIndex)
                  group.copyWith(paths: updatedPaths)
                else
                  collection.groups[j]
            ]
          )
        else
          state[i]
    ];
    _save();
  }

  // 删除路径
  void deletePath({
    required int collectionIndex,
    required int groupIndex,
    required int pathIndex,
  }) {
    final collection = state[collectionIndex];
    final group = collection.groups[groupIndex];

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == collectionIndex)
          collection.copyWith(
            groups: [
              for (int j = 0; j < collection.groups.length; j++)
                if (j == groupIndex)
                  group.copyWith(
                    paths: [...group.paths]..removeAt(pathIndex)
                  )
                else
                  collection.groups[j]
            ]
          )
        else
          state[i]
    ];
    _save();
  }
}

// 扩展后的搜索功能
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

// 递归搜索所有层级
@riverpod
List<String> searchResults(SearchResultsRef ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final collections = ref.watch(pathConfigProvider);

  final results = <String>[];

  for (final collection in collections) {
    // 匹配集合名称
    if (collection.name.toLowerCase().contains(query)) {
      results.add('Collection: ${collection.name}');
    }

    for (final group in collection.groups) {
      // 匹配组名称
      if (group.name.toLowerCase().contains(query)) {
        results.add('Group: ${collection.name} > ${group.name}');
      }

      for (final path in group.paths) {
        // 匹配路径名称
        if (path.name.toLowerCase().contains(query)) {
          results.add('Path: ${collection.name} > ${group.name} > ${path.name}');
        }
      }
    }
  }

  return results;
}

// 为数据类添加CopyWith方法
extension PathCollectionCopyWith on PathCollection {
  PathCollection copyWith({
    String? name,
    List<PathGroup>? groups,
  }) {
    return PathCollection(
      name: name ?? this.name,
      groups: groups ?? this.groups,
    );
  }
}

extension PathGroupCopyWith on PathGroup {
  PathGroup copyWith({
    String? name,
    List<PathItem>? paths,
  }) {
    return PathGroup(
      name: name ?? this.name,
      paths: paths ?? this.paths,
    );
  }
}
