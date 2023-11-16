import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:mustang_codegen/src/batch_generator/batch_model.dart';
import 'package:mustang_core/mustang_core.dart';
import 'package:source_gen/source_gen.dart';

class EnumParamVisitor extends SimpleElementVisitor<void> {
  EnumParamVisitor(
    this.serviceClassElement,
    this.batchEnum,
    this.fields,
  );

  final ClassElement serviceClassElement;

  final EnumElement batchEnum;

  List<BatchModel> fields;

  @override
  void visitMethodElement(MethodElement element) {
    Iterable<DartObject>? annotations =
        TypeChecker.fromRuntime(BatchRun).annotationsOfExact(
      element,
      throwOnUnresolved: false,
    );

    List<DartObject> steps = annotations
        .where((annotation) =>
            batchEnum.thisType == annotation.getField('step')?.type)
        .toList();

    if (steps.isNotEmpty) {
      if (element.parameters.isNotEmpty) {
        throw InvalidGenerationSourceError(
          'Service methods annotated with @BatchRun can not accept args',
          todo:
              'Don\'t accept args from the service method decorated with @BatchRun',
          element: element,
        );
      }
      fields.add(BatchModel(
        serviceClass: serviceClassElement,
        methodWithBatchRun: element,
      ));
    }
  }
}
