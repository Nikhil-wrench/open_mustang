import 'dart:async';

import 'package:build/build.dart';
import 'package:mustang_codegen/src/utils.dart';
import 'package:source_gen/source_gen.dart';

class MustangConfigBuilder implements Builder {
  static const String modelsPath = 'src/models';
  static const String configPath = 'lib/$modelsPath';
  static String configFile = '';
  static const String className = 'className';
  static const String fields = 'fields';
  static const String defaultValue = 'defaultValue';
  static const String serialize = 'serialize';
  static const String name = 'name';
  static const String type = 'type';

  @override
  Map<String, List<String>> get buildExtensions {
    dynamic mustangStateConfig = Utils.getMustangStateConfig();
    if (mustangStateConfig != null) {
      String modelName = mustangStateConfig[className];
      configFile = '${Utils.class2File(modelName)}.dart';
    } else {
      return {};
    }
    return {
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

    dynamic mustangStateConfig = Utils.getMustangStateConfig();
    if (mustangStateConfig != null) {
      modelName = mustangStateConfig[className];
      for (dynamic element in mustangStateConfig[fields]) {
        if (element != null) {
          modelFieldsList.add(element);
        } else {
          throw InvalidGenerationSourceError(
            'Error: Mustang state config fields are missing',
            todo: 'Add Mustang state config fields',
          );
        }
      }
    } else {
      return;
    }

    for (dynamic modelField in modelFieldsList) {
      if (modelField != null) {
        modelFields.writeln(_parseFields(modelField));
      } else {
        throw InvalidGenerationSourceError(
          'Error: Mustang state config fields are missing',
          todo: 'Add Mustang state config fields',
        );
      }
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
