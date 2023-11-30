// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppModelGenerator
// **************************************************************************

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'dart:core';

part 'mustang_app_states.model.g.dart';

abstract class MustangAppStates
    implements Built<MustangAppStates, MustangAppStatesBuilder> {
  MustangAppStates._();
  factory MustangAppStates([void Function(MustangAppStatesBuilder) updates]) =
      _$MustangAppStates;

  BuiltList<String> get states;

  static Serializer<MustangAppStates> get serializer =>
      _$mustangAppStatesSerializer;

  static void _initializeBuilder(MustangAppStatesBuilder builder) =>
      builder..states.addAll([]);
}
