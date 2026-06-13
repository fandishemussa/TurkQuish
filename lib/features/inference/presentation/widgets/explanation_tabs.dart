import 'package:flutter/material.dart';

import '../../../../l10n/app_strings.dart';
import '../../domain/entities/prediction_result.dart';

class ExplanationTabs extends StatelessWidget {
  const ExplanationTabs({super.key, required this.explanation});

  final LocalizedExplanation explanation;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return DefaultTabController(
      length: 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.text('explanation'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TabBar(
                tabs: [
                  Tab(text: strings.text('english')),
                  Tab(text: strings.text('turkish')),
                ],
              ),
              SizedBox(
                height: 150,
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Text(explanation.en),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Text(explanation.tr),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
