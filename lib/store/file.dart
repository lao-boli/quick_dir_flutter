import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_dir_flutter/util/log.dart';
import 'dart:io';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file.g.dart';

part 'file.freezed.dart';

abstract class IdGenerator {
  static String generate([String? prefix]) {
    return '${prefix ?? ''}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
  }
}

@unfreezed
class PathItem with _$PathItem {
  factory PathItem({
    required String id, // 新增唯一ID
    required String collectionId, // 所属集合ID
    required String groupId, // 所属组ID
    required String name,
    required String path,
  }) = _PathItem;

  factory PathItem.fromJson(Map<String, dynamic> json) =>
      _$PathItemFromJson(json);
}

@unfreezed
class PathGroup with _$PathGroup {
  factory PathGroup({
    required String id, // 新增唯一ID
    required String collectionId, // 所属集合ID
    required String name,
    @Default(<PathItem>[]) List<PathItem> paths,
  }) = _PathGroup;

  factory PathGroup.fromJson(Map<String, dynamic> json) =>
      _$PathGroupFromJson(json);
}

@unfreezed
class PathCollection with _$PathCollection {
  factory PathCollection({
    required String id, // 新增唯一ID
    required String name,
    @Default(<PathGroup>[]) List<PathGroup> groups,
  }) = _PathCollection;

  factory PathCollection.fromJson(Map<String, dynamic> json) =>
      _$PathCollectionFromJson(json);
}

@riverpod
class CurrentCollection extends _$CurrentCollection {
  @override
  PathCollection? build() {
    return null;
  }

  void setCurrentCollection(PathCollection collection) {
    state = collection;
  }

  void setCurrentCollectionById(String collectionId) {
    final collection =
        ref.read(pathConfigProvider.notifier).getCollectionById(collectionId);
    state = collection;
  }
}

@riverpod
class PathConfig extends _$PathConfig {
  @override
  List<PathCollection> build() => [];

  Future<void> load() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/path_manager.json');
    Log.i(dir.path);

    if (await file.exists()) {
      final contents = await file.readAsString();
      final jsonData = json.decode(contents);

      // 处理旧版本数据迁移
      if (jsonData['paths'] != null) {
        var defaultCollectionId = IdGenerator.generate('default_collection');
        // 旧格式转换为新格式：创建默认集合和组
        final legacyMap = Map<String, String>.from(jsonData['paths']);
        var groupId = IdGenerator.generate('default_group');
        final defaultGroup = PathGroup(
          id: groupId,
          collectionId: defaultCollectionId,
          name: 'Default Group',
          paths: legacyMap.entries
              .map((e) => PathItem(
                    id: IdGenerator.generate(e.key),
                    groupId: groupId,
                    collectionId: defaultCollectionId,
                    name: e.key,
                    path: e.value,
                  ))
              .toList(),
        );
        state = [
          PathCollection(
            id: defaultCollectionId,
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

  getCollectionById(String collectionId) {
    Log.i(collectionId);
    return state.firstWhere((collection) => collection.id == collectionId);
  }

  // 添加集合
  void addCollection(String name) {
    state = [...state, PathCollection(id: IdGenerator.generate(), name: name)];
    _save();
  }

  // 删除集合
  void deleteCollection(int collectionIndex) {
    state = [...state]..removeAt(collectionIndex);
    _save();
  }

  void addGroup(String collectionId, String groupName) {
    state = state.map((collection) {
      if (collection.id == collectionId) {
        return collection.copyWith(groups: [
          ...collection.groups,
          PathGroup(
            id: IdGenerator.generate('group'),
            collectionId: collectionId,
            name: groupName,
          )
        ]);
      }
      return collection;
    }).toList();
    _save();
    // final currentCollection = state.firstWhere((element) => element.id == )
    ref
        .read(currentCollectionProvider.notifier)
        .setCurrentCollectionById(collectionId);
    Log.i(state);
  }

  void addPath({
    required String collectionId,
    required String groupId,
    required String name,
    required String path,
  }) {
    state = state.map((collection) {
      if (collection.id == collectionId) {
        return collection.copyWith(
            groups: collection.groups.map((group) {
          if (group.id == groupId) {
            return group.copyWith(paths: [
              ...group.paths,
              PathItem(
                id: IdGenerator.generate('item'),
                collectionId: collectionId,
                groupId: groupId,
                name: name,
                path: path,
              )
            ]);
          }
          return group;
        }).toList());
      }
      return collection;
    }).toList();
    ref
        .read(currentCollectionProvider.notifier)
        .setCurrentCollectionById(collectionId);
    _save();
  }

  // 通用删除方法
  void deleteById(String targetId) {
    state = state
        .where((collection) => collection.id != targetId) // 删除集合
        .map((collection) => collection.copyWith(
            groups: collection.groups
                .where((group) => group.id != targetId) // 删除组
                .map((group) => group.copyWith(
                    paths: group.paths
                        .where((item) => item.id != targetId)
                        .toList()))
                .toList()))
        .toList();
    _save();
    final currentCollection = state.firstWhere(
        (element) => element.id == ref.read(currentCollectionProvider)?.id);
    ref
        .read(currentCollectionProvider.notifier)
        .setCurrentCollection(currentCollection);
  }

// 或更精确的定位删除：
  void deleteItem(String itemId) {
    state = state.map((collection) {
      return collection.copyWith(
          groups: collection.groups.map((group) {
        return group.copyWith(
            paths: group.paths.where((item) => item.id != itemId).toList());
      }).toList());
    }).toList();
    _save();
    final currentCollection = state.firstWhere(
        (element) => element.id == ref.read(currentCollectionProvider)?.id);
    ref
        .read(currentCollectionProvider.notifier)
        .setCurrentCollection(currentCollection);
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
    if (collection.name.toLowerCase().contains(query)) {
      results.add('Collection|${collection.id}|${collection.name}');
    }

    for (final group in collection.groups) {
      final fullPath = '${collection.name} > ${group.name}';

      if (group.name.toLowerCase().contains(query)) {
        results.add('Group|${group.id}|$fullPath');
      }

      for (final path in group.paths) {
        final fullPathWithItem = '$fullPath > ${path.name}';
        if (path.name.toLowerCase().contains(query)) {
          results.add('Path|${path.id}|$fullPathWithItem');
        }
      }
    }
  }

  return results;
}
