import 'package:analyzer/dart/element/element.dart';

class BatchModel {
  const BatchModel({
    required this.serviceClass,
    required this.methodWithBatchRun,
  });

  final ClassElement serviceClass;

  final MethodElement methodWithBatchRun;
}
