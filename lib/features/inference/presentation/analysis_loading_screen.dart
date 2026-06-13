import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/url_validator.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/loading_stepper.dart';
import '../../../l10n/app_strings.dart';
import '../../history/data/history_local_store.dart';
import '../../settings/data/settings_store.dart';
import '../data/inference_api.dart';

class AnalysisLoadingScreen extends ConsumerStatefulWidget {
  const AnalysisLoadingScreen({super.key, required this.decodedUrl});

  final String decodedUrl;

  @override
  ConsumerState<AnalysisLoadingScreen> createState() =>
      _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends ConsumerState<AnalysisLoadingScreen> {
  static const _stepKeys = [
    'analysisStepPayload',
    'analysisStepNormalization',
    'analysisStepFeatures',
    'analysisStepGraph',
    'analysisStepModel',
    'analysisStepDecision',
    'analysisStepExplanation',
  ];

  Timer? _timer;
  int _stepIndex = 0;
  ApiException? _error;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(
          () => _stepIndex = _stepIndex >= _stepKeys.length - 1
              ? _stepIndex
              : _stepIndex + 1,
        );
      }
    });
    unawaited(_startAnalysis());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    if (_started) {
      return;
    }
    _started = true;
    setState(() => _error = null);

    final validation = UrlValidator.inspect(widget.decodedUrl);
    if (!validation.isValid) {
      setState(() {
        _started = false;
        _error = ApiException(
          ApiFailureType.invalidUrl,
          AppStrings.of(context).validationError(validation),
        );
      });
      return;
    }

    try {
      final settings = ref.read(settingsStoreProvider);
      final locale = _backendLocale(settings.languageCode);
      final result = await ref
          .read(inferenceRepositoryProvider)
          .predict(decodedUrl: validation.normalizedUrl!, locale: locale);
      await ref
          .read(historyLocalStoreProvider)
          .addFromPrediction(
            result: result,
            submittedUrl: validation.normalizedUrl!,
            enabled: settings.storeHistory,
            maskQuery: settings.maskUrls,
          );
      if (mounted) {
        context.go('/result', extra: result);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _started = false;
          _error = error;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _started = false;
          _error = const ApiException(ApiFailureType.unexpected, 'unexpected');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final error = _error;
    if (error != null) {
      return Scaffold(
        body: AppErrorView(
          icon: _iconFor(error.type),
          title: strings.apiFailureTitle(error.type),
          message: error.type == ApiFailureType.unexpected
              ? strings.text('unexpectedAnalysisError')
              : strings.apiFailureMessage(error),
          primaryLabel: _canRetry(error.type) ? strings.text('retry') : null,
          onPrimary: _canRetry(error.type)
              ? () => unawaited(_startAnalysis())
              : null,
          secondaryLabel: strings.text('back'),
          onSecondary: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('analyzingUrl'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.text('backendInferenceWorkflow'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(strings.text('waitingBackendNoFetch')),
                  const SizedBox(height: 20),
                  LoadingStepper(
                    steps: [for (final key in _stepKeys) strings.text(key)],
                    currentIndex: _stepIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ApiFailureType type) {
    return switch (type) {
      ApiFailureType.developerConfig => Icons.developer_board_off_outlined,
      ApiFailureType.timeout => Icons.timer_off_outlined,
      ApiFailureType.offline => Icons.wifi_off_outlined,
      ApiFailureType.backendUnavailable => Icons.cloud_off_outlined,
      ApiFailureType.rateLimited => Icons.hourglass_top_outlined,
      ApiFailureType.serverError => Icons.dns_outlined,
      ApiFailureType.malformedResponse => Icons.data_object_outlined,
      ApiFailureType.invalidUrl => Icons.link_off,
      ApiFailureType.unexpected => Icons.error_outline,
    };
  }

  bool _canRetry(ApiFailureType type) {
    return switch (type) {
      ApiFailureType.timeout ||
      ApiFailureType.offline ||
      ApiFailureType.backendUnavailable ||
      ApiFailureType.rateLimited ||
      ApiFailureType.serverError => true,
      _ => false,
    };
  }

  String _backendLocale(String languageCode) {
    if (languageCode == 'tr' || languageCode == 'en') {
      return languageCode;
    }
    return WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
            'tr'
        ? 'tr'
        : 'en';
  }
}
