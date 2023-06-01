class After {
  const After(
    this.aspects, {
    this.args = const <String, dynamic>{},
  });

  final List<String> aspects;
  final Map<String, dynamic> args;
}
