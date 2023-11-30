// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mustang_app_states.model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<MustangAppStates> _$mustangAppStatesSerializer =
    new _$MustangAppStatesSerializer();

class _$MustangAppStatesSerializer
    implements StructuredSerializer<MustangAppStates> {
  @override
  final Iterable<Type> types = const [MustangAppStates, _$MustangAppStates];
  @override
  final String wireName = 'MustangAppStates';

  @override
  Iterable<Object?> serialize(Serializers serializers, MustangAppStates object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'states',
      serializers.serialize(object.states,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];

    return result;
  }

  @override
  MustangAppStates deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MustangAppStatesBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'states':
          result.states.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$MustangAppStates extends MustangAppStates {
  @override
  final BuiltList<String> states;

  factory _$MustangAppStates(
          [void Function(MustangAppStatesBuilder)? updates]) =>
      (new MustangAppStatesBuilder()..update(updates))._build();

  _$MustangAppStates._({required this.states}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        states, r'MustangAppStates', 'states');
  }

  @override
  MustangAppStates rebuild(void Function(MustangAppStatesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MustangAppStatesBuilder toBuilder() =>
      new MustangAppStatesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MustangAppStates && states == other.states;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, states.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MustangAppStates')
          ..add('states', states))
        .toString();
  }
}

class MustangAppStatesBuilder
    implements Builder<MustangAppStates, MustangAppStatesBuilder> {
  _$MustangAppStates? _$v;

  ListBuilder<String>? _states;
  ListBuilder<String> get states =>
      _$this._states ??= new ListBuilder<String>();
  set states(ListBuilder<String>? states) => _$this._states = states;

  MustangAppStatesBuilder() {
    MustangAppStates._initializeBuilder(this);
  }

  MustangAppStatesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _states = $v.states.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MustangAppStates other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$MustangAppStates;
  }

  @override
  void update(void Function(MustangAppStatesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MustangAppStates build() => _build();

  _$MustangAppStates _build() {
    _$MustangAppStates _$result;
    try {
      _$result = _$v ?? new _$MustangAppStates._(states: states.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'states';
        states.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'MustangAppStates', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
