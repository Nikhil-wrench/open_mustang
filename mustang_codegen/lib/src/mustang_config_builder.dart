import 'dart:async';

import 'package:build/build.dart';
import 'package:mustang_codegen/src/utils.dart';

class MustangConfigBuilder implements Builder {
  static const String modelsPath = 'src/models';
  static const String configPath = 'lib/$modelsPath';
  static const String configFile = 'mustang_state.dart';
  static const String className = 'className';
  static const String fields = 'fields';
  static const String defaultValue = 'defaultValue';
  static const String serialize = 'serialize';
  static const String name = 'name';
  static const String type = 'type';
  

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': ['$modelsPath/$configFile'],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    String modelName = '';
    final List<dynamic> modelFieldsList = [];
    final StringBuffer modelFields = StringBuffer();

    // get the current app package
    String pkgName = buildStep.inputId.package;
    AssetId outFile = AssetId(pkgName, '$configPath/$configFile');

    dynamic customConfigPackage = Utils.getCustomConfigPackage();
    if (customConfigPackage != null) {
      modelName = customConfigPackage[className];
      for (dynamic element in customConfigPackage[fields]) {
        if (element.isNotEmpty) {
          modelFieldsList.add(element);
        }
      }
    }

    for (dynamic modelField in modelFieldsList) {
      modelFields.writeln(_parseFields(modelField));
    }

    String out = _generate(
      modelName,
      modelFields.toString(),
    );
    await buildStep.writeAsString(outFile, out);
  }

  static String _generate(
    String modelName,
    String modelFields,
  ) {
    return '''
${Utils.defaultGeneratorComment} 

// **************************************************************************
// MustangConfigBuilder
// **************************************************************************
   
import 'package:mustang_core/mustang_core.dart';

@appModel
@appEventGlobal
abstract class \$$modelName {
$modelFields
}''';
  }

  static String _parseFields(dynamic modelField) {
    return '''
    @InitField(${modelField[defaultValue]})
    @SerializeField(${modelField[serialize]})
    late ${modelField[type]} ${modelField[name]};
    ''';
  }
}
