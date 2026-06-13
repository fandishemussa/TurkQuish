import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../l10n/app_strings.dart';
import '../../inference/data/inference_api.dart';

enum FeedbackType { correct, falsePositive, falseNegative, unsure }

extension FeedbackTypeX on FeedbackType {
  String get wireName {
    return switch (this) {
      FeedbackType.correct => 'correct',
      FeedbackType.falsePositive => 'false_positive',
      FeedbackType.falseNegative => 'false_negative',
      FeedbackType.unsure => 'unsure',
    };
  }
}

class FeedbackSheet extends ConsumerStatefulWidget {
  const FeedbackSheet({super.key, required this.predictionId});

  final String predictionId;

  @override
  ConsumerState<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<FeedbackSheet> {
  final _commentController = TextEditingController();
  FeedbackType _type = FeedbackType.correct;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(inferenceRepositoryProvider)
          .submitFeedback(
            predictionId: widget.predictionId,
            feedbackType: _type.wireName,
            comment: _commentController.text,
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      setState(() => _error = AppStrings.of(context).apiFailureMessage(error));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.text('reportFeedback'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in FeedbackType.values)
                ChoiceChip(
                  label: Text(_labelFor(type, strings)),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: strings.text('feedbackOptionalComment'),
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(strings.text('sendFeedback')),
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(FeedbackType type, AppStrings strings) {
    return switch (type) {
      FeedbackType.correct => strings.text('feedbackCorrect'),
      FeedbackType.falsePositive => strings.text('feedbackFalsePositive'),
      FeedbackType.falseNegative => strings.text('feedbackFalseNegative'),
      FeedbackType.unsure => strings.text('feedbackUnsure'),
    };
  }
}
