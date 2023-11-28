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
      'states',
      serializers.serialize(object.states,
          specifiedType: const FullType(BuiltMap, const [
            const FullType(String),
            const FullType(BuiltList, const [const FullType(String)])
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
        case 'states':
          result.states.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap, const [
                const FullType(String),
                const FullType(BuiltList, const [const FullType(String)])
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
  final BuiltMap<String, BuiltList<String>> states;

  factory _$MustangAppConfig(
          [void Function(MustangAppConfigBuilder)? updates]) =>
      (new MustangAppConfigBuilder()..update(updates))._build();

  _$MustangAppConfig._({required this.config, required this.states})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        config, r'MustangAppConfig', 'config');
    BuiltValueNullFieldError.checkNotNull(
        states, r'MustangAppConfig', 'states');
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
        states == other.states;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jc(_$hash, states.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MustangAppConfig')
          ..add('config', config)
          ..add('states', states))
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

  MapBuilder<String, BuiltList<String>>? _states;
  MapBuilder<String, BuiltList<String>> get states =>
      _$this._states ??= new MapBuilder<String, BuiltList<String>>();
  set states(MapBuilder<String, BuiltList<String>>? states) =>
      _$this._states = states;

  MustangAppConfigBuilder() {
    MustangAppConfig._initializeBuilder(this);
  }

  MustangAppConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _config = $v.config.toBuilder();
      _states = $v.states.toBuilder();
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
              config: config.build(), states: states.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'config';
        config.build();
        _$failedField = 'states';
        states.build();
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
