// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PathNodeImpl _$$PathNodeImplFromJson(Map<String, dynamic> json) =>
    _$PathNodeImpl(
      label: json['label'] as String,
      path: json['path'] as String?,
      data: json['data'],
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => PathNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PathNode>[],
      isExpanded: json['isExpanded'] as bool? ?? false,
    );

Map<String, dynamic> _$$PathNodeImplToJson(_$PathNodeImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'path': instance.path,
      'data': instance.data,
      'children': instance.children,
      'isExpanded': instance.isExpanded,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pathTreeHash() => r'37ee1906c5ce9cf3545eb0fd40f6da49a124c2dd';

/// See also [PathTree].
@ProviderFor(PathTree)
final pathTreeProvider =
    AutoDisposeNotifierProvider<PathTree, List<PathNode>>.internal(
  PathTree.new,
  name: r'pathTreeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pathTreeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PathTree = AutoDisposeNotifier<List<PathNode>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
