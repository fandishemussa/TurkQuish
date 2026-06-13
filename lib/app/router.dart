import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_error_view.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/inference/domain/entities/prediction_result.dart';
import '../features/inference/presentation/analysis_loading_screen.dart';
import '../features/inference/presentation/result_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/scanner/presentation/scanner_screen.dart';
import '../features/scanner/presentation/url_preview_screen.dart';
import '../features/settings/presentation/backend_status_screen.dart';
import '../features/settings/presentation/privacy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../l10n/app_strings.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/preview',
        builder: (context, state) =>
            UrlPreviewScreen(decodedUrl: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) =>
            AnalysisLoadingScreen(decodedUrl: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final result = state.extra;
          if (result is PredictionResult) {
            return ResultScreen(result: result);
          }
          final strings = AppStrings.of(context);
          return Scaffold(
            body: AppErrorView(
              icon: Icons.error_outline,
              title: strings.text('resultUnavailable'),
              message: strings.text('resultUnavailableMessage'),
            ),
          );
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/backend-status',
        builder: (context, state) => const BackendStatusScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/config-error',
        builder: (context, state) => const DeveloperConfigErrorScreen(),
      ),
    ],
  );
});
