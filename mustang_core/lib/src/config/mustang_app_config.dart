import 'package:built_collection/built_collection.dart';
import 'package:mustang_core/src/annotations/app_event_global.dart';
import 'package:mustang_core/src/annotations/app_model.dart';
import 'package:mustang_core/src/annotations/init_field.dart';
import 'package:mustang_core/src/annotations/serialize_field.dart';

@appModel
@appEventGlobal
abstract class $MustangAppConfig {
  @InitField({})
  @SerializeField(false)
  late BuiltMap<String, Object> config;
}
