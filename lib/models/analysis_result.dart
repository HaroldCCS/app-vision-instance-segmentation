class AnalysisResult {
  final String text;
  final List<String> objects;

  const AnalysisResult({
    required this.text,
    required this.objects,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      text: json['text'] as String? ?? '',
      objects: List<String>.from(json['objects'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'objects': objects,
      };
}
