import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:mustang_codegen/src/utils.dart';
import 'package:source_gen/source_gen.dart';

class ScreenGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    Iterable<Element> elements = library.element.topLevelElements;
    if (elements.isEmpty) {
      return '';
    }

    String declaration = library.element.topLevelElements
            .map((e) => e.declaration?.getDisplayString(withNullability: false))
            .toList()
            .first ??
        '';

    if (declaration.isNotEmpty &&
            declaration.contains('extends StatelessWidget') ||
        declaration.contains('extends StatefulWidget')) {
      _validate(library.element);
    }

    return '';
  }

  void _validate(Element element) {
    Utils.getRawImports(element.library?.libraryImports ?? [])
        .forEach((import) {
      if (import.isNotEmpty && import.contains('mustang_core.dart')) {
        throw InvalidGenerationSourceError(
            'Error: Screen class should not import mustang_core.dart',
            element: element);
      }
    });
  }
}
