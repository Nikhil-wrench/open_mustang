import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class Utils {
  static const String debugEventKind = 'mustang';
  static const String debugObjectMutationEventKind = 'object:mutate';
  static const String debugPersistObjectEventKind = 'object:persist';
  static const String debugCacheObjectEventKind = 'object:cache';

  // mustang config file
  static const String configFile = 'mustang.yaml';

  // Keys in mustang.yaml
  static const String mustangStateConfigKey = 'mustangStateConfig';
  static const String serializerKey = 'serializer';
  static const String screenKey = 'screen';
  static const String screenImportsKey = 'imports';

  static String class2File(String className) {
    RegExp exp = RegExp(r'(?<=[0-9a-z])[A-Z]');
    return className
        .replaceAllMapped(exp, (Match m) => ('_${m.group(0) ?? ''}'))
        .toLowerCase();
  }

  static String stateClassToGenServiceFile(String stateClassName) {
    String stateFileName = class2File(stateClassName);
    return stateFileName.replaceFirst(
        RegExp('_state\$'), '_service.service.dart');
  }

  static String serviceClassToGenStateFile(String serviceClassName) {
    String serviceFileName = class2File(serviceClassName);
    return serviceFileName.replaceFirst(
        RegExp('_service\$'), '_state.state.dart');
  }

  static String stateClassToGenServiceClass(String stateClassName) {
    String stateFileName = class2File(stateClassName);
    String genServiceFileName =
        stateFileName.replaceFirst(RegExp('_state\$'), '_service');
    String firstPass =
        genServiceFileName.replaceAllMapped(RegExp('_([a-z])'), (Match m) {
      return (m.group(1)?.toUpperCase() ?? '');
    });
    return capitalizeFirst(firstPass);
  }

  static String serviceClass2GenStateClass(String serviceClassName) {
    String serviceFileName = class2File(serviceClassName);
    String genStateFileName =
        serviceFileName.replaceFirst(RegExp('_service\$'), '_state');
    String firstPass =
        genStateFileName.replaceAllMapped(RegExp('_([a-z])'), (Match m) {
      return (m.group(1)?.toUpperCase() ?? '');
    });
    return capitalizeFirst(firstPass);
  }

  static String class2Var(String className) {
    String firstLetter = className.substring(0, 1).toLowerCase();
    return '$firstLetter${className.substring(1)}';
  }

  static String capitalizeFirst(String str) {
    String firstLetter = str.substring(0, 1).toUpperCase();
    return '$firstLetter${str.substring(1)}';
  }

  static String pkg2Var(String pkgName) {
    return class2Var(
        pkgName.split('_').map((e) => capitalizeFirst(e)).toList().join(''));
  }

  static String getImportFromPath(String package, String path) {
    return "import 'package:$package/${path.replaceAll('lib/', '')}';";
  }

  static List<String> getImports(List<LibraryImportElement> elements) {
    List<String> importsList = [];
    for (LibraryImportElement importElement in elements) {
      String importedLib =
          '${importElement.importedLibrary?.definingCompilationUnit.declaration ?? ''}';
      if (importedLib.isNotEmpty && !importedLib.contains('mustang_core')) {
        if (importedLib.startsWith('dart:')) {
          importsList.add("import '$importedLib';");
        } else if (importedLib.contains('/models/')) {
          if (importedLib.contains('.model.dart')) {
            // Supports the case where some of the models inside Model classes
            // are built_value classes but are not generated using
            // @appModel annotation
            importsList.add(
                "import 'package:${importedLib.substring(1).replaceAll('/lib/', '/')}';");
          } else {
            importsList.add(
                "import 'package:${importedLib.substring(1).replaceAll('/lib/', '/').replaceFirst('.dart', '.model.dart')}';");
          }
        } else {
          importsList.add(
              "import 'package:${importedLib.substring(1).replaceAll('/lib/', '/')}';");
        }
      }
    }
    return importsList;
  }

  static List<String> getRawImports(List<LibraryImportElement> elements) {
    return elements
        .map((importElement) =>
            '${importElement.importedLibrary?.definingCompilationUnit.declaration ?? ''}')
        .toList();
  }

  static String? getCustomSerializerPackage() {
    dynamic yamlConfig = getYamlConfig();
    if (yamlConfig != null && yamlConfig[serializerKey] != null) {
      return yamlConfig[serializerKey];
    }
    return null;
  }

  static dynamic getMustangStateConfig() {
    dynamic yamlConfig = getYamlConfig();
    if (yamlConfig != null && yamlConfig[mustangStateConfigKey] != null) {
      return yamlConfig[mustangStateConfigKey];
    }
    return null;
  }

  static dynamic getYamlConfig() {
    String configFilePath = p.join(p.current, configFile);
    if (configFilePath.isNotEmpty && File(configFilePath).existsSync()) {
      File configFile = File(configFilePath);
      String rawConfig = configFile.readAsStringSync();
      return loadYaml(rawConfig);
    }
    return null;
  }

  /// Input: MethodElement
  /// Output: Method with all its input arguments
  /// Example Output: validateToken(userId: userId, token: token)
  static String methodWithExecutionArgs(
    MethodElement element,
    List<String> imports, {
    String declarationInvocation = 'super',
  }) {
    String methodWithArguments =
        '$declarationInvocation.${element.displayName}(';
    if (element.parameters.isNotEmpty) {
      element.parameters.toList().forEach((parameter) {
        String importForParam =
            parameter.type.element?.location?.encoding ?? '';

        if (importForParam.isNotEmpty) {
          importForParam = importForParam.split(';').first;
          String customSerializerPackage =
              Utils.getCustomSerializerPackage() ?? '';
          List<String> importForParamTokens = importForParam.split('/');
          List<String> customSerializerPackageTokens =
              customSerializerPackage.split('/');

          if (customSerializerPackageTokens.isNotEmpty &&
              importForParamTokens.isNotEmpty) {
            if (importForParamTokens.first ==
                customSerializerPackageTokens.first) {
              imports.add("import '$customSerializerPackage';");
            } else {
              imports.add("import '$importForParam';");
            }
          }
        }
        if (parameter.declaration.isNamed) {
          methodWithArguments =
              '$methodWithArguments${parameter.displayName}: ${parameter.displayName}, ';
        } else {
          methodWithArguments =
              '$methodWithArguments${parameter.displayName}, ';
        }
      });
    }
    methodWithArguments = '$methodWithArguments)';
    return methodWithArguments;
  }

  static String defaultGeneratorComment = '// GENERATED CODE - DO NOT MODIFY';
}
