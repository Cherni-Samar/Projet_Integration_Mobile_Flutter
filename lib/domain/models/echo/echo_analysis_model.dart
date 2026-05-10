class EchoAnalysis {
  final String? summary;
  final bool isUrgent;
  final String priority;
  final List<String> actions;
  final String? category;
  final String? transcribedText;

  const EchoAnalysis({
    this.summary,
    required this.isUrgent,
    required this.priority,
    required this.actions,
    this.category,
    this.transcribedText,
  });
}
