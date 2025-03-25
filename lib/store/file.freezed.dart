// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PathItem _$PathItemFromJson(Map<String, dynamic> json) {
  return _PathItem.fromJson(json);
}

/// @nodoc
mixin _$PathItem {
  String get id => throw _privateConstructorUsedError;
  set id(String value) => throw _privateConstructorUsedError; // 新增唯一ID
  String get collectionId => throw _privateConstructorUsedError; // 新增唯一ID
  set collectionId(String value) =>
      throw _privateConstructorUsedError; // 所属集合ID
  String get groupId => throw _privateConstructorUsedError; // 所属集合ID
  set groupId(String value) => throw _privateConstructorUsedError; // 所属组ID
  String get name => throw _privateConstructorUsedError; // 所属组ID
  set name(String value) => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  set path(String value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PathItemCopyWith<PathItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PathItemCopyWith<$Res> {
  factory $PathItemCopyWith(PathItem value, $Res Function(PathItem) then) =
      _$PathItemCopyWithImpl<$Res, PathItem>;
  @useResult
  $Res call(
      {String id,
      String collectionId,
      String groupId,
      String name,
      String path});
}

/// @nodoc
class _$PathItemCopyWithImpl<$Res, $Val extends PathItem>
    implements $PathItemCopyWith<$Res> {
  _$PathItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? collectionId = null,
    Object? groupId = null,
    Object? name = null,
    Object? path = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PathItemImplCopyWith<$Res>
    implements $PathItemCopyWith<$Res> {
  factory _$$PathItemImplCopyWith(
          _$PathItemImpl value, $Res Function(_$PathItemImpl) then) =
      __$$PathItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String collectionId,
      String groupId,
      String name,
      String path});
}

/// @nodoc
class __$$PathItemImplCopyWithImpl<$Res>
    extends _$PathItemCopyWithImpl<$Res, _$PathItemImpl>
    implements _$$PathItemImplCopyWith<$Res> {
  __$$PathItemImplCopyWithImpl(
      _$PathItemImpl _value, $Res Function(_$PathItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? collectionId = null,
    Object? groupId = null,
    Object? name = null,
    Object? path = null,
  }) {
    return _then(_$PathItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PathItemImpl implements _PathItem {
  _$PathItemImpl(
      {required this.id,
      required this.collectionId,
      required this.groupId,
      required this.name,
      required this.path});

  factory _$PathItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PathItemImplFromJson(json);

  @override
  String id;
// 新增唯一ID
  @override
  String collectionId;
// 所属集合ID
  @override
  String groupId;
// 所属组ID
  @override
  String name;
  @override
  String path;

  @override
  String toString() {
    return 'PathItem(id: $id, collectionId: $collectionId, groupId: $groupId, name: $name, path: $path)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PathItemImplCopyWith<_$PathItemImpl> get copyWith =>
      __$$PathItemImplCopyWithImpl<_$PathItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PathItemImplToJson(
      this,
    );
  }
}

abstract class _PathItem implements PathItem {
  factory _PathItem(
      {required String id,
      required String collectionId,
      required String groupId,
      required String name,
      required String path}) = _$PathItemImpl;

  factory _PathItem.fromJson(Map<String, dynamic> json) =
      _$PathItemImpl.fromJson;

  @override
  String get id;
  set id(String value);
  @override // 新增唯一ID
  String get collectionId; // 新增唯一ID
  set collectionId(String value);
  @override // 所属集合ID
  String get groupId; // 所属集合ID
  set groupId(String value);
  @override // 所属组ID
  String get name; // 所属组ID
  set name(String value);
  @override
  String get path;
  set path(String value);
  @override
  @JsonKey(ignore: true)
  _$$PathItemImplCopyWith<_$PathItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PathGroup _$PathGroupFromJson(Map<String, dynamic> json) {
  return _PathGroup.fromJson(json);
}

/// @nodoc
mixin _$PathGroup {
  String get id => throw _privateConstructorUsedError;
  set id(String value) => throw _privateConstructorUsedError; // 新增唯一ID
  String get collectionId => throw _privateConstructorUsedError; // 新增唯一ID
  set collectionId(String value) =>
      throw _privateConstructorUsedError; // 所属集合ID
  String get name => throw _privateConstructorUsedError; // 所属集合ID
  set name(String value) => throw _privateConstructorUsedError;
  List<PathItem> get paths => throw _privateConstructorUsedError;
  set paths(List<PathItem> value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PathGroupCopyWith<PathGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PathGroupCopyWith<$Res> {
  factory $PathGroupCopyWith(PathGroup value, $Res Function(PathGroup) then) =
      _$PathGroupCopyWithImpl<$Res, PathGroup>;
  @useResult
  $Res call(
      {String id, String collectionId, String name, List<PathItem> paths});
}

/// @nodoc
class _$PathGroupCopyWithImpl<$Res, $Val extends PathGroup>
    implements $PathGroupCopyWith<$Res> {
  _$PathGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? collectionId = null,
    Object? name = null,
    Object? paths = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      paths: null == paths
          ? _value.paths
          : paths // ignore: cast_nullable_to_non_nullable
              as List<PathItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PathGroupImplCopyWith<$Res>
    implements $PathGroupCopyWith<$Res> {
  factory _$$PathGroupImplCopyWith(
          _$PathGroupImpl value, $Res Function(_$PathGroupImpl) then) =
      __$$PathGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String collectionId, String name, List<PathItem> paths});
}

/// @nodoc
class __$$PathGroupImplCopyWithImpl<$Res>
    extends _$PathGroupCopyWithImpl<$Res, _$PathGroupImpl>
    implements _$$PathGroupImplCopyWith<$Res> {
  __$$PathGroupImplCopyWithImpl(
      _$PathGroupImpl _value, $Res Function(_$PathGroupImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? collectionId = null,
    Object? name = null,
    Object? paths = null,
  }) {
    return _then(_$PathGroupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      paths: null == paths
          ? _value.paths
          : paths // ignore: cast_nullable_to_non_nullable
              as List<PathItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PathGroupImpl implements _PathGroup {
  _$PathGroupImpl(
      {required this.id,
      required this.collectionId,
      required this.name,
      this.paths = const <PathItem>[]});

  factory _$PathGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$PathGroupImplFromJson(json);

  @override
  String id;
// 新增唯一ID
  @override
  String collectionId;
// 所属集合ID
  @override
  String name;
  @override
  @JsonKey()
  List<PathItem> paths;

  @override
  String toString() {
    return 'PathGroup(id: $id, collectionId: $collectionId, name: $name, paths: $paths)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PathGroupImplCopyWith<_$PathGroupImpl> get copyWith =>
      __$$PathGroupImplCopyWithImpl<_$PathGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PathGroupImplToJson(
      this,
    );
  }
}

abstract class _PathGroup implements PathGroup {
  factory _PathGroup(
      {required String id,
      required String collectionId,
      required String name,
      List<PathItem> paths}) = _$PathGroupImpl;

  factory _PathGroup.fromJson(Map<String, dynamic> json) =
      _$PathGroupImpl.fromJson;

  @override
  String get id;
  set id(String value);
  @override // 新增唯一ID
  String get collectionId; // 新增唯一ID
  set collectionId(String value);
  @override // 所属集合ID
  String get name; // 所属集合ID
  set name(String value);
  @override
  List<PathItem> get paths;
  set paths(List<PathItem> value);
  @override
  @JsonKey(ignore: true)
  _$$PathGroupImplCopyWith<_$PathGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PathCollection _$PathCollectionFromJson(Map<String, dynamic> json) {
  return _PathCollection.fromJson(json);
}

/// @nodoc
mixin _$PathCollection {
  String get id => throw _privateConstructorUsedError;
  set id(String value) => throw _privateConstructorUsedError; // 新增唯一ID
  String get name => throw _privateConstructorUsedError; // 新增唯一ID
  set name(String value) => throw _privateConstructorUsedError;
  List<PathGroup> get groups => throw _privateConstructorUsedError;
  set groups(List<PathGroup> value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PathCollectionCopyWith<PathCollection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PathCollectionCopyWith<$Res> {
  factory $PathCollectionCopyWith(
          PathCollection value, $Res Function(PathCollection) then) =
      _$PathCollectionCopyWithImpl<$Res, PathCollection>;
  @useResult
  $Res call({String id, String name, List<PathGroup> groups});
}

/// @nodoc
class _$PathCollectionCopyWithImpl<$Res, $Val extends PathCollection>
    implements $PathCollectionCopyWith<$Res> {
  _$PathCollectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? groups = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      groups: null == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as List<PathGroup>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PathCollectionImplCopyWith<$Res>
    implements $PathCollectionCopyWith<$Res> {
  factory _$$PathCollectionImplCopyWith(_$PathCollectionImpl value,
          $Res Function(_$PathCollectionImpl) then) =
      __$$PathCollectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, List<PathGroup> groups});
}

/// @nodoc
class __$$PathCollectionImplCopyWithImpl<$Res>
    extends _$PathCollectionCopyWithImpl<$Res, _$PathCollectionImpl>
    implements _$$PathCollectionImplCopyWith<$Res> {
  __$$PathCollectionImplCopyWithImpl(
      _$PathCollectionImpl _value, $Res Function(_$PathCollectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? groups = null,
  }) {
    return _then(_$PathCollectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      groups: null == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as List<PathGroup>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PathCollectionImpl implements _PathCollection {
  _$PathCollectionImpl(
      {required this.id,
      required this.name,
      this.groups = const <PathGroup>[]});

  factory _$PathCollectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PathCollectionImplFromJson(json);

  @override
  String id;
// 新增唯一ID
  @override
  String name;
  @override
  @JsonKey()
  List<PathGroup> groups;

  @override
  String toString() {
    return 'PathCollection(id: $id, name: $name, groups: $groups)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PathCollectionImplCopyWith<_$PathCollectionImpl> get copyWith =>
      __$$PathCollectionImplCopyWithImpl<_$PathCollectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PathCollectionImplToJson(
      this,
    );
  }
}

abstract class _PathCollection implements PathCollection {
  factory _PathCollection(
      {required String id,
      required String name,
      List<PathGroup> groups}) = _$PathCollectionImpl;

  factory _PathCollection.fromJson(Map<String, dynamic> json) =
      _$PathCollectionImpl.fromJson;

  @override
  String get id;
  set id(String value);
  @override // 新增唯一ID
  String get name; // 新增唯一ID
  set name(String value);
  @override
  List<PathGroup> get groups;
  set groups(List<PathGroup> value);
  @override
  @JsonKey(ignore: true)
  _$$PathCollectionImplCopyWith<_$PathCollectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
