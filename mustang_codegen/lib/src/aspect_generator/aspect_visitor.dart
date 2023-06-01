import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:mustang_codegen/src/codegen_constants.dart';

/// Visits an aspect file and finds all parameters for the run method
class AspectVisitor extends SimpleElementVisitor<void> {
  const AspectVisitor(
    this.invokeParameters,
  );

  final List<ParameterElement> invokeParameters;

  @override
  void visitMethodElement(MethodElement element) {
    switch (element.displayName) {
      case CodeGenConstants.aspectMethod:
        invokeParameters.addAll(element.parameters.toList());
        break;
    }
    super.visitMethodElement(element);
  }
}
