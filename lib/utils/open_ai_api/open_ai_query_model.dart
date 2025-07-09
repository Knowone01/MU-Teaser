class HFQuery {
  final String inputs;
  final Map<String, dynamic> parameters;

  HFQuery({
    required this.inputs,
    this.parameters = const {'max_new_tokens': 150, 'temperature': 0.7},
  });

  Map<String, dynamic> toJson() {
    return {'inputs': inputs, 'parameters': parameters};
  }
}
