import 'dart:typed_data';

class FormGlobalStatusWrapper<T> {
  bool listeningToChangeEvents = true;
  final Map<String, T?> variables = {
    "idPredio": null,
    "noEdificio": null,
    "noLocal": null,
  };
  Map<String, List<void Function(T?)>> _variablesOnChangedSuscribedFunctions =
      {};
  FormGlobalStatusWrapper() {
    for (var variable in variables.keys) {
      _variablesOnChangedSuscribedFunctions[variable] = [];
    }
  }
  operator [](String key) => variables[key];
  operator []=(String key, T? value) {
    variables[key] = value;
    if (!listeningToChangeEvents) return;
    for (var onChagedFunction in _variablesOnChangedSuscribedFunctions[key]!) {
      print("""
        /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
        /\/\/\/\/\/\/\/\/\/\/\/\   ejecutando $onChagedFunction
        /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
""");
      onChagedFunction(value);
    }
  }

  void suscribeToVariableChangeEvent({
    required String variable,
    required void Function(T?) onChanged,
  }) {
    _variablesOnChangedSuscribedFunctions[variable]!.add(onChanged);
  }
}
