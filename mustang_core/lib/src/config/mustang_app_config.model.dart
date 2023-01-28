// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:core';

import 'package:built_collection/built_collection.dart';
// **************************************************************************
// AppModelGenerator
// **************************************************************************

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:mustang_core/mustang_core.dart';

part 'mustang_app_config.model.g.dart';

abstract class MustangAppConfig
    implements Built<MustangAppConfig, MustangAppConfigBuilder>, AppEvent {
  MustangAppConfig._();
  factory MustangAppConfig([void Function(MustangAppConfigBuilder) updates]) =
      _$MustangAppConfig;

  @BuiltValueField(serialize: false)
  BuiltMap<String, Object> get config;

  static Serializer<MustangAppConfig> get serializer =>
      _$mustangAppConfigSerializer;

  static void _initializeBuilder(MustangAppConfigBuilder builder) =>
      builder..config.addAll({});
}
