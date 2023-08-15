import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:mustang_codegen/src/codegen_constants.dart';
import 'package:mustang_codegen/src/service_generator/service_method_override_visitor.dart';
import 'package:mustang_codegen/src/utils.dart';
import 'package:mustang_core/mustang_core.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

class ScreenServiceGenerator extends Generator {
  static const String appModelsDir = 'lib/src/models';
  static const String appAspectsDir = 'lib/src/aspects';
  static const String additionalServiceDir = '/ext/';

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    Iterable<AnnotatedElement> services =
        library.annotatedWith(const TypeChecker.fromRuntime(ScreenService));
    StringBuffer serviceBuffer = StringBuffer();
    if (services.isEmpty) {
      return '$serviceBuffer';
    }

    // if the file is an additional service, skip processing
    String serviceFilePath =
        services.first.element.source?.uri.normalizePath().toString() ?? '';
    if (serviceFilePath.contains(additionalServiceDir)) {
      return '$serviceBuffer';
    }

    serviceBuffer.writeln(await _generate(
      services.first.element,
      services.first.annotation,
      buildStep,
    ));

    return '$serviceBuffer';
  }

  Future<String> _generate(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    _validate(element);

    String serviceName = element.displayName;
    String generatedServiceName = element.displayName.replaceFirst(r'$', '');
    String importService = p.basenameWithoutExtension(buildStep.inputId.path);

    String screenState = Utils.serviceClass2GenStateClass(generatedServiceName);
    if (screenState.isEmpty) {
      return '';
    }

    // parse aspect files
    List<LibraryElement> aspectLibraries = [];
    await for (AssetId assetId
        in buildStep.findAssets(Glob('$appAspectsDir/*_aspect.dart'))) {
      LibraryElement library = await buildStep.resolver.libraryFor(assetId);
      aspectLibraries.add(library);
    }

    List<String> overriders = [];
    List<String> imports = [];
    element.visitChildren(
      ServiceMethodOverrideVisitor(
        overrides: overriders,
        imports: imports,
        aspectLibraries: aspectLibraries,
      ),
    );

    // parse additional screen services
    List<String> additionalServiceNames = [];
    List<String> serviceFilePathSegments = buildStep.inputId.pathSegments;
    serviceFilePathSegments.removeLast();
    await for (AssetId assetId in buildStep.findAssets(Glob(
        '${p.joinAll(serviceFilePathSegments)}/${CodeGenConstants.extendedServicesDir}/*_service.dart'))) {
      LibraryElement library = await buildStep.resolver.libraryFor(assetId);
      String additionalServiceName = library.topLevelElements.first.displayName;
      additionalServiceNames.add(additionalServiceName);
      _validate(library.topLevelElements.first, isAdditionalService: true);
      imports.add(Utils.getImportFromPath(assetId.package, assetId.path));
      library.topLevelElements.first.visitChildren(ServiceMethodOverrideVisitor(
        overrides: overriders,
        imports: imports,
        aspectLibraries: aspectLibraries,
      ));
    }

    imports.add(
        "import '${Utils.serviceClassToGenStateFile(generatedServiceName)}';");
    imports = imports.toSet().toList();

    String statePath = buildStep.inputId.uri
        .toString()
        .replaceFirst('_service.dart', '_state.dart');
    AssetId stateAssetId = AssetId.resolve(Uri.parse(statePath));
    LibraryElement stateLibraryElement =
        await buildStep.resolver.libraryFor(stateAssetId);
    ClassElement stateClassElement =
        LibraryReader(stateLibraryElement).classes.first;
    List<String> stateFieldsTypes =
        stateClassElement.fields.map((e) => e.type.toString()).toList();

    String pkgName = buildStep.inputId.package;
    String appSerializerAlias = 'app_serializer';

    String? customSerializerPackage = Utils.getCustomSerializerPackage();
    String customSerializer = '';
    String customSerializerAlias = '';
    if (customSerializerPackage != null) {
      AssetId assetId = AssetId.resolve(Uri.parse(customSerializerPackage));
      customSerializerAlias = '${assetId.package}_serializer';
      customSerializer =
          "import '$customSerializerPackage' as $customSerializerAlias;";
    }

    List<String> appEventModels = [CodeGenConstants.defaultMustangModel];
    List<String> appEventModelImports = [];
    await for (AssetId assetId
        in buildStep.findAssets(Glob('$appModelsDir/*[!.model.]*'))) {
      LibraryElement appModelLibrary =
          await buildStep.resolver.libraryFor(assetId);
      Iterable<AnnotatedElement> appEvents = LibraryReader(appModelLibrary)
          .annotatedWith(const TypeChecker.fromRuntime(AppEvent));
      Iterable<AnnotatedElement> appEventsGlobal =
          LibraryReader(appModelLibrary)
              .annotatedWith(const TypeChecker.fromRuntime(AppEventGlobal));

      if (appEvents.isNotEmpty || appEventsGlobal.isNotEmpty) {
        bool isAppEventGlobal = appEvents.isEmpty && appEventsGlobal.isNotEmpty;

        String appEvent = isAppEventGlobal
            ? appEventsGlobal.first.element.name!
            : appEvents.first.element.name!;

        if (isAppEventGlobal || _stateHasAppEvent(appEvent, stateFieldsTypes)) {
          appEventModels.add(appEvent);
          String importPath =
              assetId.uri.toString().replaceFirst('dart', 'model.dart');
          appEventModelImports.add("import '$importPath';");
        }
      }
    }

    return '''
      import 'package:mustang_core/mustang_core.dart';
      import '$importService.dart';
      import 'dart:convert';
      import 'dart:developer';
      import 'package:flutter/foundation.dart';
      import 'package:$pkgName/src/models/serializers.dart' as $appSerializerAlias;
      $customSerializer
      ${appEventModelImports.join('\n')}
      ${imports.join('\n')}
      
      class _\$${screenState}Cache<T> {
        const _\$${screenState}Cache([this.t]);
        
        Map<String, dynamic> toJson() {
          return {
            '\$T': '\$t',
          };
        }
      
        final T? t;
      }
      
      class $generatedServiceName extends $serviceName {
        Future<void> subscribeToEventStream() async {
          ${_generateEventSubscription(appEventModels, stateFieldsTypes)}
        }
        
        ${overriders.join('\n')}
      }
      
      ${_generateServiceExtensions(additionalServiceNames, serviceName)}
        
      class _${serviceName}Utils {
        void updateState() {
          $screenState? screenState = MustangStore.get<$screenState>();
          if (screenState != null) {
            screenState.update();
          }
        }
        
        void updateState1<T>(T t, {
          reload = true,
        }) {
          MustangStore.update(t);
          if (MustangStore.persistent) {
            ${_generatePersistObjectTemplate('T', appSerializerAlias, customSerializerAlias)}
            if (kDebugMode) {
              postEvent('$serviceName: ${Utils.debugPersistObjectEventKind}', {
                'models': '\$T',
              });
            }
          }
          if (kDebugMode) {
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$T',
              'modelStr': ${_generateJsonObject('T', appSerializerAlias, customSerializerAlias)},
            });
          }
          if (reload) {
            $screenState? screenState = MustangStore.get<$screenState>();
            if (screenState != null) {
              screenState.update();
            }
          }
        }
    
        void updateState2<T, S>(T t, S s, {
          reload = true,
        }) {
          MustangStore.update2(t, s);
          if (MustangStore.persistent) {
            ${_generatePersistObjectTemplate('T', appSerializerAlias, customSerializerAlias)}
            ${_generatePersistObjectTemplate('S', appSerializerAlias, customSerializerAlias)}
            if (kDebugMode) {
              postEvent('$serviceName: ${Utils.debugPersistObjectEventKind}', {
                'models': '\$T, \$S',
              });
            }
          }
          if (kDebugMode) {
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$T',
              'modelStr': ${_generateJsonObject('T', appSerializerAlias, customSerializerAlias)},
            });
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$S',
              'modelStr': ${_generateJsonObject('S', appSerializerAlias, customSerializerAlias)},
            });
          }
          if (reload) {
            $screenState? screenState = MustangStore.get<$screenState>();
            if (screenState != null) {
              screenState.update();
            }
          }
        }
    
        void updateState3<T, S, U>(T t, S s, U u, {
          reload = true,
        }) {
          MustangStore.update3(t, s, u);
          if (MustangStore.persistent) {
            ${_generatePersistObjectTemplate('T', appSerializerAlias, customSerializerAlias)}
            ${_generatePersistObjectTemplate('S', appSerializerAlias, customSerializerAlias)}
            ${_generatePersistObjectTemplate('U', appSerializerAlias, customSerializerAlias)}
            if (kDebugMode) {
              postEvent('$serviceName: ${Utils.debugPersistObjectEventKind}', {
                'models': '\$T, \$S, \$U',
              });
            }
          }
          if (kDebugMode) {
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$T',
              'modelStr': ${_generateJsonObject('T', appSerializerAlias, customSerializerAlias)},
            });
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$S',
              'modelStr': ${_generateJsonObject('S', appSerializerAlias, customSerializerAlias)},
            });
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$U',
              'modelStr': ${_generateJsonObject('U', appSerializerAlias, customSerializerAlias)},
            });
          }
          if (reload) {
            $screenState? screenState = MustangStore.get<$screenState>();
            if (screenState != null) {
              screenState.update();
            }
          }
        }
    
        void updateState4<T, S, U, V>(T t, S s, U u, V v, {
          reload = true,
        }) {
          MustangStore.update4(t, s, u, v);
          if (MustangStore.persistent) {
            ${_generatePersistObjectTemplate('T', appSerializerAlias, customSerializerAlias)}
            ${_generatePersistObjectTemplate('S', appSerializerAlias, customSerializerAlias)}
            ${_generatePersistObjectTemplate('U', appSerializerAlias, customSerializerAlias)}
            ${_generatePersistObjectTemplate('V', appSerializerAlias, customSerializerAlias)}
            if (kDebugMode) {
              postEvent('$serviceName: ${Utils.debugPersistObjectEventKind}', {
                'models': '\$T, \$S, \$U, \$V',
              });
            }
          }
          if (kDebugMode) {
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$T',
              'modelStr': ${_generateJsonObject('T', appSerializerAlias, customSerializerAlias)},
            });
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$S',
              'modelStr': ${_generateJsonObject('S', appSerializerAlias, customSerializerAlias)},
            });
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$U',
              'modelStr': ${_generateJsonObject('U', appSerializerAlias, customSerializerAlias)},
            });
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\$V',
              'modelStr': ${_generateJsonObject('V', appSerializerAlias, customSerializerAlias)},
            });
          }
          if (reload) {
            $screenState? screenState = MustangStore.get<$screenState>();
            if (screenState != null) {
              screenState.update();
            }
          }
        }
        
        T memoizeScreen<T>(T Function() service) {
          _\$${screenState}Cache screenStateCache =
              MustangStore.get<_\$${screenState}Cache>() ?? const _\$${screenState}Cache();
          
          if (screenStateCache.t == null) {
            T t = service();
            screenStateCache = _\$${screenState}Cache(t);
            MustangStore.update(screenStateCache);
            if (kDebugMode) {
              postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
                'model': '\${_\$${screenState}Cache}',
                'modelStr': screenStateCache.toJson(),
              });
            }
          }
          return screenStateCache.t;
        }
        
        Future<void> clearMemoizedScreen({
          reload = true,
        }) async {
          await MustangStore.delete<_\$${screenState}Cache>();
          if (kDebugMode) {
            postEvent('$serviceName: ${Utils.debugObjectMutationEventKind}', {
              'model': '\${_\$${screenState}Cache}',
              'modelStr': '{}',
            });
          }
          if (reload) {
            $screenState? screenState = MustangStore.get<$screenState>();
            if (screenState != null) {
              screenState.update();
            }
          }    
        }
        
        Future<void> addObjectToCache<T>(String key, T t) async {
          if (kDebugMode) {
            postEvent('$serviceName: ${Utils.debugCacheObjectEventKind}', {
                'model': '\$T',
            });
          }
          await MustangCache.addObject(
            key,
            '\$T',
            ${_generateCacheObjectJsonArg('T', appSerializerAlias, customSerializerAlias)},
          );
        }
        
        Future<void> deleteObjectsFromCache(String key) async {
          await MustangCache.deleteObjects(key);
        }
        
        bool itemExistsInCache(String key) {
          return MustangCache.itemExists(key);
        }
      }
    ''';
  }

  String _generateEventSubscription(
    List<String> appEventModels,
    List<String> stateFieldsTypes,
  ) {
    String instanceCheckStr = '';

    for (String appEventModel in appEventModels) {
      String modelName = appEventModel.replaceFirst('\$', '');
      instanceCheckStr += '''
        if (event is $modelName) {
          updateState1(event);
        }
      ''';
    }

    return '''
      Stream<AppEvent> appEventStream = await EventStream.getStream();
      await for (AppEvent event in appEventStream) {
        $instanceCheckStr
    }''';
  }

  String _generatePersistObjectTemplate(
    String type,
    String appSerializerAlias,
    String customSerializerAlias,
  ) {
    if (customSerializerAlias.isNotEmpty) {
      return '''MustangStore.persistObject(
        '\$$type',
        jsonEncode(
          $appSerializerAlias.serializerNames.contains('\$$type')
              ? $appSerializerAlias.serializers.serialize(${type.toLowerCase()})
              : $customSerializerAlias.serializers.serialize(${type.toLowerCase()}),
        ),
      );''';
    } else {
      return '''MustangStore.persistObject(
        '\$$type',
        jsonEncode($appSerializerAlias.serializers.serialize(${type.toLowerCase()})),
      );''';
    }
  }

  String _generateCacheObjectJsonArg(
    String type,
    String appSerializerAlias,
    String customSerializerAlias,
  ) {
    if (customSerializerAlias.isNotEmpty) {
      return '''
        jsonEncode($appSerializerAlias.serializerNames.contains('\$$type')
                  ? $appSerializerAlias.serializers.serialize(${type.toLowerCase()})
                  : $customSerializerAlias.serializers.serialize(${type.toLowerCase()}))
    ''';
    } else {
      return '''jsonEncode($appSerializerAlias.serializers.serialize(${type.toLowerCase()}))''';
    }
  }

  String _generateJsonObject(
    String type,
    String appSerializerAlias,
    String customSerializerAlias,
  ) {
    if (customSerializerAlias.isNotEmpty) {
      return '''
        jsonDecode(jsonEncode($appSerializerAlias.serializerNames.contains('\$$type')
                  ? $appSerializerAlias.serializers.serialize(${type.toLowerCase()})
                  : $customSerializerAlias.serializers.serialize(${type.toLowerCase()})))
    ''';
    } else {
      return 'jsonDecode(jsonEncode($appSerializerAlias.serializers.serialize(${type.toLowerCase()})))';
    }
  }

  void _validate(
    Element element, {
    bool isAdditionalService = false,
  }) {
    if (!element.displayName.startsWith(r'$')) {
      throw InvalidGenerationSourceError(
          'ScreenService class name should start with \$',
          todo: 'Prefix class name with \$',
          element: element);
    }

    List<String> modelImports =
        Utils.getRawImports(element.library?.libraryImports ?? []);
    if (modelImports
            .indexWhere((element) => element.contains('material.dart')) !=
        -1) {
      throw InvalidGenerationSourceError(
        'Error: Service class should not import flutter library',
        element: element,
      );
    }

    // class annotated with ScreenService should be abstract or mixin if
    // the service is a mixin
    if (isAdditionalService) {
      bool isMixin = element is MixinElement;
      if (!isMixin) {
        throw InvalidGenerationSourceError(
            'Error: additional screen services in ext folder should be mixin',
            todo: 'Make additional services as mixin',
            element: element);
      }
    } else {
      ClassElement appServiceClass = element as ClassElement;
      if (!appServiceClass.isAbstract) {
        throw InvalidGenerationSourceError(
            'Error: class annotated with ScreenService should be abstract',
            todo: 'Make the class abstract ',
            element: element);
      }
    }
  }

  bool _stateHasAppEvent(String appEvent, List<String> stateFieldsTypes) {
    return stateFieldsTypes.contains(appEvent);
  }

  String _generateServiceExtensions(
    List<String> serviceNames,
    String screenService,
  ) {
    String out = '';
    serviceNames.add(screenService);
    for (String serviceName in serviceNames) {
      String utilClass = '_${screenService}Utils';
      out += '''\n\n
      extension \$$serviceName on $serviceName {
        void updateState() {
          $utilClass().updateState();
        }
        
        void updateState1<T>(T t, {
          reload = true,
        }) {
          $utilClass().updateState1(t, reload: reload);
        }
    
        void updateState2<T, S>(T t, S s, {
          reload = true,
        }) {
          $utilClass().updateState2(t, s, reload: reload);
        }
    
        void updateState3<T, S, U>(T t, S s, U u, {
          reload = true,
        }) {
          $utilClass().updateState3(t, s, u, reload: reload);
        }
    
        void updateState4<T, S, U, V>(T t, S s, U u, V v, {
          reload = true,
        }) {
          $utilClass().updateState4(t, s, u, v, reload: reload);
        }
        
        T memoizeScreen<T>(T Function() service) {
          return $utilClass().memoizeScreen(service);
        }
        
        void clearMemoizedScreen({
          reload = true,
        }) {
          $utilClass().clearMemoizedScreen(reload: reload);    
        }
        
        Future<void> addObjectToCache<T>(String key, T t) async {
          await $utilClass().addObjectToCache(key, t);
        }
        
        Future<void> deleteObjectsFromCache(String key) async {
          await $utilClass().deleteObjectsFromCache(key);
        }
        
        bool itemExistsInCache(String key) {
          return $utilClass().itemExistsInCache(key); 
        }
      }
    ''';
    }
    return out;
  }
}
