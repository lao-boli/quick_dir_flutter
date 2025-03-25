// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tree.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PathNode _$PathNodeFromJson(Map<String, dynamic> json) {
  return _PathNode.fromJson(json);
}

/// @nodoc
mixin _$PathNode {
  String get label => throw _privateConstructorUsedError;
  set label(String value) => throw _privateConstructorUsedError;
  String? get path => throw _privateConstructorUsedError;
  set path(String? value) => throw _privateConstructorUsedError;
  Object? get data => throw _privateConstructorUsedError;
  set data(Object? value) => throw _privateConstructorUsedError;
  List<PathNode> get children => throw _privateConstructorUsedError;
  set children(List<PathNode> value) => throw _privateConstructorUsedError;
  bool get isExpanded => throw _privateConstructorUsedError;
  set isExpanded(bool value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PathNodeCopyWith<PathNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PathNodeCopyWith<$Res> {
  factory $PathNodeCopyWith(PathNode value, $Res Function(PathNode) then) =
      _$PathNodeCopyWithImpl<$Res, PathNode>;
  @useResult
  $Res call(
      {String label,
      String? path,
      Object? data,
      List<PathNode> children,
      bool isExpanded});
}

/// @nodoc
class _$PathNodeCopyWithImpl<$Res, $Val extends PathNode>
    implements $PathNodeCopyWith<$Res> {
  _$PathNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? path = freezed,
    Object? data = freezed,
    Object? children = null,
    Object? isExpanded = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data ? _value.data : data,
      children: null == children
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<PathNode>,
      isExpanded: null == isExpanded
          ? _value.isExpanded
          : isExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PathNodeImplCopyWith<$Res>
    implements $PathNodeCopyWith<$Res> {
  factory _$$PathNodeImplCopyWith(
          _$PathNodeImpl value, $Res Function(_$PathNodeImpl) then) =
      __$$PathNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String label,
      String? path,
      Object? data,
      List<PathNode> children,
      bool isExpanded});
}

/// @nodoc
class __$$PathNodeImplCopyWithImpl<$Res>
    extends _$PathNodeCopyWithImpl<$Res, _$PathNodeImpl>
    implements _$$PathNodeImplCopyWith<$Res> {
  __$$PathNodeImplCopyWithImpl(
      _$PathNodeImpl _value, $Res Function(_$PathNodeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? path = freezed,
    Object? data = freezed,
    Object? children = null,
    Object? isExpanded = null,
  }) {
    return _then(_$PathNodeImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data ? _value.data : data,
      children: null == children
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<PathNode>,
      isExpanded: null == isExpanded
          ? _value.isExpanded
          : isExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PathNodeImpl implements _PathNode {
  _$PathNodeImpl(
      {required this.label,
      this.path,
      this.data,
      this.children = const <PathNode>[],
      this.isExpanded = false});

  factory _$PathNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PathNodeImplFromJson(json);

  @override
  String label;
  @override
  String? path;
  @override
  Object? data;
  @override
  @JsonKey()
  List<PathNode> children;
  @override
  @JsonKey()
  bool isExpanded;

  @override
  String toString() {
    return 'PathNode(label: $label, path: $path, data: $data, children: $children, isExpanded: $isExpanded)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PathNodeImplCopyWith<_$PathNodeImpl> get copyWith =>
      __$$PathNodeImplCopyWithImpl<_$PathNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PathNodeImplToJson(
      this,
    );
  }
}

abstract class _PathNode implements PathNode {
  factory _PathNode(
      {required String label,
      String? path,
      Object? data,
      List<PathNode> children,
      bool isExpanded}) = _$PathNodeImpl;

  factory _PathNode.fromJson(Map<String, dynamic> json) =
      _$PathNodeImpl.fromJson;

  @override
  String get label;
  set label(String value);
  @override
  String? get path;
  set path(String? value);
  @override
  Object? get data;
  set data(Object? value);
  @override
  List<PathNode> get children;
  set children(List<PathNode> value);
  @override
  bool get isExpanded;
  set isExpanded(bool value);
  @override
  @JsonKey(ignore: true)
  _$$PathNodeImplCopyWith<_$PathNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
