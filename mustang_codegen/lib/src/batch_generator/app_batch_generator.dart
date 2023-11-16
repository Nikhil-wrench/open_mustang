import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:mustang_codegen/src/batch_generator/batch_model.dart';
import 'package:mustang_codegen/src/batch_generator/enum_param_visitor.dart';
import 'package:mustang_core/mustang_core.dart';
import 'package:source_gen/source_gen.dart';

class AppBatchGenerator implements Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    Iterable<AnnotatedElement> annotatedElements =
        library.annotatedWith(TypeChecker.fromRuntime(Batch));

    StringBuffer appBatchBuffer = StringBuffer();

    String res = await _generateBatch(buildStep, annotatedElements.first);
    appBatchBuffer.writeln(res);

    return '$appBatchBuffer';
  }

  Future<String> _generateBatch(
    BuildStep buildStep,
    AnnotatedElement annotedElement,
  ) async {
    EnumElement batch = annotedElement.element as EnumElement;
    List<BatchModel> batchModels = [];
    List<String> imports = [];

    await for (AssetId assetId
        in buildStep.findAssets(Glob('lib/src/**/*_service.dart'))) {
      LibraryElement serviceFile = await buildStep.resolver.libraryFor(assetId);
      for (Element serviceClass in serviceFile.topLevelElements) {
        List<BatchModel> serviceBatchMethods = [];

        serviceClass.visitChildren(
          EnumParamVisitor(
            serviceClass as ClassElement,
            batch,
            serviceBatchMethods,
          ),
        );

        if (serviceBatchMethods.isNotEmpty) {
          String? package = serviceClass.librarySource.uri.toString();
          package = package.split('.').join('.service.');
          imports.add("import '$package';");
          batchModels.addAll(serviceBatchMethods);
        }
      }
    }

    List<String> steps = batch.fields.map((e) => e.displayName).toList();
    batchModels.sort(
      (a, b) {
        int indexOfA = steps.indexWhere((element) {
          DartObject? annotation =
              TypeChecker.fromRuntime(BatchRun).firstAnnotationOf(
            a.methodWithBatchRun,
            throwOnUnresolved: false,
          );

          return annotation?.getField('step')?.variable?.displayName == element;
        });

        int indexOfB = steps.indexWhere((element) {
          DartObject? annotation =
              TypeChecker.fromRuntime(BatchRun).firstAnnotationOf(
            b.methodWithBatchRun,
            throwOnUnresolved: false,
          );

          return annotation?.getField('step')?.variable?.displayName == element;
        });

        return indexOfA.compareTo(indexOfB);
      },
    );

    List<String> methodStatements = [];

    for (BatchModel batchModel in batchModels) {
      String serviceClassName =
          batchModel.serviceClass.displayName.split('\$').lastOrNull ?? '';

      methodStatements.add(
        '$serviceClassName().${batchModel.methodWithBatchRun.displayName}',
      );
    }

    String className = batch.displayName.split('\$').last;

    return '''
    import 'dart:async';
    ${imports.join('\n')}

    class $className {
      static Future<void> run() async {
        final List<Function> calls = [${methodStatements.join(',')}];
        
        for(int i = 0; i < calls.length; i++) {
          Function method = calls.elementAt(i);
    
          await Future(() async => await method());
        }
      }
    }
    ''';
  }
}
