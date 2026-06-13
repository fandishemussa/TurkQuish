class FeedbackRequestDto {
  const FeedbackRequestDto({
    required this.predictionId,
    required this.feedbackType,
    required this.clientTimestamp,
    this.comment,
  });

  final String predictionId;
  final String feedbackType;
  final String? comment;
  final DateTime clientTimestamp;

  Map<String, dynamic> toJson() {
    return {
      'predictionId': predictionId,
      'feedbackType': feedbackType,
      'comment': comment?.trim().isEmpty ?? true ? null : comment!.trim(),
      'clientTimestamp': clientTimestamp.toUtc().toIso8601String(),
    };
  }
}
