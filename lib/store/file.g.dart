// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PathItemImpl _$$PathItemImplFromJson(Map<String, dynamic> json) =>
    _$PathItemImpl(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
    );

Map<String, dynamic> _$$PathItemImplToJson(_$PathItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'groupId': instance.groupId,
      'name': instance.name,
      'path': instance.path,
    };

_$PathGroupImpl _$$PathGroupImplFromJson(Map<String, dynamic> json) =>
    _$PathGroupImpl(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      name: json['name'] as String,
      paths: (json['paths'] as List<dynamic>?)
              ?.map((e) => PathItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PathItem>[],
    );

Map<String, dynamic> _$$PathGroupImplToJson(_$PathGroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'name': instance.name,
      'paths': instance.paths,
    };

_$PathCollectionImpl _$$PathCollectionImplFromJson(Map<String, dynamic> json) =>
    _$PathCollectionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => PathGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PathGroup>[],
    );

Map<String, dynamic> _$$PathCollectionImplToJson(
        _$PathCollectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'groups': instance.groups,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchResultsHash() => r'd1f355457e865839be3c38884b8596300b27c8b0';

/// See also [searchResults].
@ProviderFor(searchResults)
final searchResultsProvider = AutoDisposeProvider<List<String>>.internal(
  searchResults,
  name: r'searchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SearchResultsRef = AutoDisposeProviderRef<List<String>>;
String _$pathConfigHash() => r'a8cd5c14373fe83b7c235c96fb8234e32ed433e0';

/// See also [PathConfig].
@ProviderFor(PathConfig)
final pathConfigProvider =
    AutoDisposeNotifierProvider<PathConfig, List<PathCollection>>.internal(
  PathConfig.new,
  name: r'pathConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pathConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PathConfig = AutoDisposeNotifier<List<PathCollection>>;
String _$searchQueryHash() => r'c20c8b67cdf9a8c8820d422de83c580e88655dcd';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
