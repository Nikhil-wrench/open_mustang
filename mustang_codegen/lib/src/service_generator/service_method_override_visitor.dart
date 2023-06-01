import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:mustang_codegen/src/aspect_generator/aspect_visitor.dart';
import 'package:mustang_codegen/src/codegen_constants.dart';
import 'package:mustang_codegen/src/utils.dart';
import 'package:mustang_core/mustang_core.dart';
import 'package:source_gen/source_gen.dart';

/// Parses all the methods of a service and service extension files
/// looking for annotations, @Around, and generate appropriate code. This visitor
/// is called from [ScreenServiceGenerator]
class ServiceMethodOverrideVisitor extends SimpleElementVisitor<void> {
  ServiceMethodOverrideVisitor({
    required this.overrides,
    required this.imports,
    required this.aspectLibraries,
  });

  List<String> overrides;
  List<String> imports;
  List<LibraryElement> aspectLibraries;

  @override
  void visitMethodElement(MethodElement element) {
    List<ElementAnnotation> annotations = element.declaration.metadata.toList();
    // if there are no annotations skip this method
    if (annotations.isNotEmpty) {
      String methodWithExecutionArgs = Utils.methodWithExecutionArgs(
        element,
        imports,
      );
      List<String> beforeHooks = [];
      List<String> afterHooks = [];
      List<String> aroundHooks = [];

      final DartObject? beforeAnnotationObject =
          TypeChecker.fromRuntime(Before).firstAnnotationOfExact(element);
      if (beforeAnnotationObject != null) {
        _generateBeforeHooks(
          element,
          beforeAnnotationObject,
          beforeHooks,
          imports,
          aspectLibraries,
        );
      }

      final DartObject? afterAnnotationObject =
          TypeChecker.fromRuntime(After).firstAnnotationOfExact(element);
      if (afterAnnotationObject != null) {
        _generateAfterHooks(
          element,
          afterAnnotationObject,
          afterHooks,
          imports,
          aspectLibraries,
        );
      }

      final DartObject? aroundAnnotationObject =
          TypeChecker.fromRuntime(Around).firstAnnotationOfExact(element);
      if (aroundAnnotationObject != null) {
        _generateAroundHooks(
          element,
          aroundAnnotationObject,
          aroundHooks,
          imports,
          aspectLibraries,
        );
      }

      if (beforeAnnotationObject != null ||
          afterAnnotationObject != null ||
          aroundAnnotationObject != null) {
        _validateSourceMethodAsync(element);
      }

      String nestedAroundMethods = _nestAroundMethods(
        methodWithExecutionArgs,
        aroundHooks,
      );

      String declaration =
          element.declaration.getDisplayString(withNullability: false);

      overrides.add('''
          @override
          $declaration async {
            ${beforeHooks.join('')}
            await ${aroundHooks.isEmpty ? methodWithExecutionArgs : nestedAroundMethods};
            ${afterHooks.join('')}
          }
        ''');

      return super.visitMethodElement(element);
    }
  }

  void _generateBeforeHooks(
    MethodElement element,
    DartObject beforeAnnotationObject,
    List<String> beforeHooks,
    List<String> imports,
    List<LibraryElement> aspectLibraries,
  ) {
    Map<DartObject?, DartObject?> args =
        beforeAnnotationObject.getField('args')!.toMapValue()!;
    Map<String, dynamic> argsMap = {};
    for (var e in args.entries) {
      argsMap["'${e.key!.toStringValue()!}'"] = _getTypeValue(e.value);
    }

    List<DartObject> aspects =
        beforeAnnotationObject.getField('aspects')?.toListValue() ?? [];

    if (aspects.isEmpty) {
      throw InvalidGenerationSourceError(
        'Error: No before aspects found or failed to resolve aspect(s) type',
        element: element,
      );
    }

    for (DartObject aspect in aspects) {
      Iterable<LibraryElement> matchedAspects = aspectLibraries.where(
        (element) =>
            element.topLevelElements.first.name == aspect.toStringValue(),
      );

      if (matchedAspects.isEmpty) {
        throw InvalidGenerationSourceError(
          'Error: Invalid aspect name',
          element: element,
        );
      }
      List<ParameterElement> invokeParameters = [];
      Element aspectExtensionObject =
          matchedAspects.first.topLevelElements.first;
      aspectExtensionObject.visitChildren(AspectVisitor(invokeParameters));

      _validateBeforeOrAfterAspectParameters(
        element,
        invokeParameters,
        aspect.type,
      );
      String annotationImport =
          aspectExtensionObject.librarySource!.uri.normalizePath().toString();
      annotationImport = annotationImport.replaceFirst('.dart', '.aspect.dart');
      if (annotationImport.isNotEmpty) {
        annotationImport = annotationImport.split(';').first;
        imports.add("import '$annotationImport';");
      }
      String methodName = CodeGenConstants.invoke;
      String aspectName = '\$${aspect.toStringValue()}';
      beforeHooks.add('''
              await $aspectName().$methodName($argsMap);
            ''');
    }
  }

  void _generateAfterHooks(
    MethodElement element,
    DartObject afterAnnotationObject,
    List<String> afterHooks,
    List<String> imports,
    List<LibraryElement> aspectLibraries,
  ) {
    Map<DartObject?, DartObject?> args =
        afterAnnotationObject.getField('args')!.toMapValue()!;
    Map<String, dynamic> argsMap = {};
    for (var e in args.entries) {
      argsMap["'${e.key!.toStringValue()!}'"] = _getTypeValue(e.value);
    }

    List<DartObject> aspects =
        afterAnnotationObject.getField('aspects')?.toListValue() ?? [];
    if (aspects.isEmpty) {
      throw InvalidGenerationSourceError(
        'Error: No after aspects found or failed to resolve aspect(s) type',
        element: element,
      );
    }

    for (DartObject aspect in aspects) {
      Iterable<LibraryElement> matchedAspects = aspectLibraries.where(
        (element) =>
            element.topLevelElements.first.name == aspect.toStringValue(),
      );

      if (matchedAspects.isEmpty) {
        throw InvalidGenerationSourceError(
          'Error: Invalid aspect name',
          element: element,
        );
      }
      List<ParameterElement> invokeParameters = [];
      Element aspectExtensionObject =
          matchedAspects.first.topLevelElements.first;
      aspectExtensionObject.visitChildren(AspectVisitor(invokeParameters));

      _validateBeforeOrAfterAspectParameters(
        element,
        invokeParameters,
        aspect.type,
      );
      String annotationImport =
          aspectExtensionObject.librarySource!.uri.normalizePath().toString();
      annotationImport = annotationImport.replaceFirst('.dart', '.aspect.dart');
      if (annotationImport.isNotEmpty) {
        annotationImport = annotationImport.split(';').first;
        imports.add("import '$annotationImport';");
      }
      String methodName = CodeGenConstants.invoke;
      String aspectName = '\$${aspect.toStringValue()}';
      afterHooks.add('''
              await $aspectName().$methodName($argsMap);
            ''');
    }
  }

  void _generateAroundHooks(
    MethodElement element,
    DartObject aroundAnnotationObject,
    List<String> aroundHooks,
    List<String> imports,
    List<LibraryElement> aspectLibraries,
  ) {
    Map<DartObject?, DartObject?> args =
        aroundAnnotationObject.getField('args')!.toMapValue()!;
    Map<String, dynamic> argsMap = {};
    for (var e in args.entries) {
      argsMap["'${e.key!.toStringValue()!}'"] = _getTypeValue(e.value);
    }

    DartObject? aspect = aroundAnnotationObject.getField('aspect');
    if (aspect == null) {
      throw InvalidGenerationSourceError(
        'Error: Failed to around resolve aspect type',
        element: element,
      );
    }

    Iterable<LibraryElement> matchedAspects = aspectLibraries.where((element) =>
        element.topLevelElements.first.name == aspect.toStringValue());
    if (matchedAspects.isEmpty) {
      throw InvalidGenerationSourceError(
        'Error: Invalid aspect name',
        element: element,
      );
    }

    Element aspectExtensionObject = matchedAspects.first.topLevelElements.first;
    List<ParameterElement> invokeParameters = [];
    aspectExtensionObject.visitChildren(AspectVisitor(invokeParameters));
    _validateAroundInvokeParameters(
      element,
      invokeParameters,
    );

    String annotationImport =
        aspectExtensionObject.librarySource!.uri.normalizePath().toString();
    annotationImport = annotationImport.replaceFirst('.dart', '.aspect.dart');
    if (annotationImport.isNotEmpty) {
      annotationImport = annotationImport.split(';').first;
      imports.add("import '$annotationImport';");
    }
    String methodName = CodeGenConstants.invoke;
    String aspectName = '\$${aspect.toStringValue()}';
    aroundHooks.add('''
              $aspectName().$methodName($argsMap,
            ''');
  }

  String _nestAroundMethods(
    String methodWithExecutionArgs,
    List<String> aroundHooks,
  ) {
    String aroundHook = 'await $methodWithExecutionArgs';
    for (String s in aroundHooks.reversed) {
      aroundHook = '$s () async { $aroundHook';
    }
    String closing =
        List.generate(aroundHooks.length, (index) => ';})').join('');
    aroundHook = '''
        $aroundHook$closing
      ''';
    return aroundHook;
  }

  dynamic _getTypeValue(DartObject? dartObject) {
    if (dartObject == null) {
      return dartObject;
    }

    switch ('${dartObject.type}') {
      case 'int':
        return dartObject.toIntValue();
      case 'double':
        return dartObject.toDoubleValue();
      case 'String':
        return "'${dartObject.toStringValue()}'";
      case 'bool':
        return dartObject.toBoolValue();
      default:
        return null;
    }
  }

  void _validateSourceMethodAsync(MethodElement element) {
    if (!element.returnType.isDartAsyncFuture) {
      throw InvalidGenerationSourceError(
        '''Error: Annotated methods must be async and return a Future. 
  example: 
      @Before([sampleAspect])
      Future<void> sourceMethod() async {
        print('Source method -> run'); 
      }''',
        todo: 'Make sure generated aspect files don\'t have errors',
        element: element,
      );
    }
  }

  void _validateAroundInvokeParameters(
    MethodElement element,
    List<ParameterElement> invokeParameters,
  ) {
    if (invokeParameters.isEmpty) {
      throw InvalidGenerationSourceError(
        '''Error: Around aspects must accept sourceMethod as an argument.
  example:
    @invoke 
    Future<void> run(Map<String, dynamic> args, Function sourceMethod) async {
      print('before sourceMethod');
      await sourceMethod();
      print('after sourceMethod');
    }''',
        todo: 'Make sure generated aspect files don\'t have errors',
        element: element,
      );
    }

    if (invokeParameters.length > 1 &&
        !invokeParameters.last.type.isDartCoreFunction) {
      throw InvalidGenerationSourceError(
        '''Error: Around aspects must only accept sourceMethod as an argument.
  example: 
    @invoke 
    Future<void> run(Map<String, dynamic> args, Function sourceMethod) async {
      print('before sourceMethod ');
      await sourceMethod();
      print('after sourceMethod');
    }
    
 ${invokeParameters.length} Found: ${invokeParameters.join(', ')}''',
        todo: 'Make sure generated aspect files don\'t have errors',
      );
    }
  }

  void _validateBeforeOrAfterAspectParameters(
    MethodElement element,
    List<ParameterElement> invokeParameters,
    DartType? annotationType,
  ) {
    if (invokeParameters.length > 1) {
      throw InvalidGenerationSourceError(
        'Error: Method annotated with @invoke in \$$annotationType expects ${invokeParameters.join(', ')} as argument\n',
        todo: 'Make sure generated aspect files don\'t have errors',
        element: element,
      );
    }
  }
}
