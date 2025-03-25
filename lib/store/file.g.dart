// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

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
