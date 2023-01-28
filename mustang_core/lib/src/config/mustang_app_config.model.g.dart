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
    return <Object?>[];
  }

  @override
  MustangAppConfig deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return new MustangAppConfigBuilder().build();
  }
}

class _$MustangAppConfig extends MustangAppConfig {
  @override
  final BuiltMap<String, Object> config;

  factory _$MustangAppConfig(
          [void Function(MustangAppConfigBuilder)? updates]) =>
      (new MustangAppConfigBuilder()..update(updates))._build();

  _$MustangAppConfig._({required this.config}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        config, r'MustangAppConfig', 'config');
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
    return other is MustangAppConfig && config == other.config;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MustangAppConfig')
          ..add('config', config))
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

  MustangAppConfigBuilder() {
    MustangAppConfig._initializeBuilder(this);
  }

  MustangAppConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _config = $v.config.toBuilder();
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
      _$result = _$v ?? new _$MustangAppConfig._(config: config.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'config';
        config.build();
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
