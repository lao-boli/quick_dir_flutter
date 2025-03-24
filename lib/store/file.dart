import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file.g.dart'; // 生成的代码文件
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
  final keys =
      ref.watch(pathConfigProvider.select((value) => value.keys.toList()));
  keys.sort();
  return keys.where((key) => key.toLowerCase().contains(query)).toList();
}
