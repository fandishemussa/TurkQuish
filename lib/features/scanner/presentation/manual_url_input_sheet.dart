import 'package:flutter/material.dart';

import '../../../core/utils/url_validator.dart';
import '../../../l10n/app_strings.dart';

class ManualUrlInputSheet extends StatefulWidget {
  const ManualUrlInputSheet({super.key});

  @override
  State<ManualUrlInputSheet> createState() => _ManualUrlInputSheetState();
}

class _ManualUrlInputSheetState extends State<ManualUrlInputSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final result = UrlValidator.inspect(_controller.text);
    if (!result.isValid) {
      setState(() => _error = AppStrings.of(context).validationError(result));
      return;
    }
    Navigator.of(context).pop(result.normalizedUrl);
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
            strings.text('manualUrlInput'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.link),
              labelText: 'https://example.com/login',
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.text('cancel')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(strings.text('preview')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
