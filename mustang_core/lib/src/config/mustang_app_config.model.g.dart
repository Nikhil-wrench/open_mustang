// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mustang_app_config.model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<MustangAppConfig> _$mustangAppConfigSerializer =
    new _$MustangAppConfigSerializer();

class _$MustangAppConfigSerializer
    implements StructuredSerializer<MustangAppConfig> {
  @override
  final Iterable<Type> types = const [MustangAppConfig, _$MustangAppConfig];
  @override
  final String wireName = 'MustangAppConfig';

  @override
  Iterable<Object?> serialize(Serializers serializers, MustangAppConfig object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'config',
      serializers.serialize(object.config,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(String), const FullType(Object)])),
      'stateMap',
      serializers.serialize(object.stateMap,
          specifiedType: const FullType(BuiltMap, const [
            const FullType(String),
            const FullType(MustangAppStates)
          ])),
    ];

    return result;
  }

  @override
  MustangAppConfig deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MustangAppConfigBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'config':
          result.config.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap,
                  const [const FullType(String), const FullType(Object)]))!);
          break;
        case 'stateMap':
          result.stateMap.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap, const [
                const FullType(String),
                const FullType(MustangAppStates)
              ]))!);
          break;
      }
    }

    return result.build();
  }
}

class _$MustangAppConfig extends MustangAppConfig {
  @override
  final BuiltMap<String, Object> config;
  @override
  final BuiltMap<String, MustangAppStates> stateMap;

  factory _$MustangAppConfig(
          [void Function(MustangAppConfigBuilder)? updates]) =>
      (new MustangAppConfigBuilder()..update(updates))._build();

  _$MustangAppConfig._({required this.config, required this.stateMap})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        config, r'MustangAppConfig', 'config');
    BuiltValueNullFieldError.checkNotNull(
        stateMap, r'MustangAppConfig', 'stateMap');
  }

  @override
  MustangAppConfig rebuild(void Function(MustangAppConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MustangAppConfigBuilder toBuilder() =>
      new MustangAppConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MustangAppConfig &&
        config == other.config &&
        stateMap == other.stateMap;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jc(_$hash, stateMap.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MustangAppConfig')
          ..add('config', config)
          ..add('stateMap', stateMap))
        .toString();
  }
}

class MustangAppConfigBuilder
    implements Builder<MustangAppConfig, MustangAppConfigBuilder> {
  _$MustangAppConfig? _$v;

  MapBuilder<String, Object>? _config;
  MapBuilder<String, Object> get config =>
      _$this._config ??= new MapBuilder<String, Object>();
  set config(MapBuilder<String, Object>? config) => _$this._config = config;

  MapBuilder<String, MustangAppStates>? _stateMap;
  MapBuilder<String, MustangAppStates> get stateMap =>
      _$this._stateMap ??= new MapBuilder<String, MustangAppStates>();
  set stateMap(MapBuilder<String, MustangAppStates>? stateMap) =>
      _$this._stateMap = stateMap;

  MustangAppConfigBuilder() {
    MustangAppConfig._initializeBuilder(this);
  }

  MustangAppConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _config = $v.config.toBuilder();
      _stateMap = $v.stateMap.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MustangAppConfig other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$MustangAppConfig;
  }

  @override
  void update(void Function(MustangAppConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MustangAppConfig build() => _build();

  _$MustangAppConfig _build() {
    _$MustangAppConfig _$result;
    try {
      _$result = _$v ??
          new _$MustangAppConfig._(
              config: config.build(), stateMap: stateMap.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'config';
        config.build();
        _$failedField = 'stateMap';
        stateMap.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'MustangAppConfig', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
