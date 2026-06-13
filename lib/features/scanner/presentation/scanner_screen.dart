import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/url_validator.dart';
import '../../../l10n/app_strings.dart';
import '../../settings/data/settings_store.dart';
import '../data/qr_scanner_service.dart';
import 'manual_url_input_sheet.dart';

enum ScannerStatus {
  idle,
  detecting,
  qrDetected,
  invalidPayload,
  readyForPreview,
  submitting,
  error,
}

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  final _scannerService = const QrScannerService();
  late final MobileScannerController _controller;
  ScannerStatus _status = ScannerStatus.idle;
  PermissionStatus? _permissionStatus;
  String? _lastPayload;
  DateTime? _lastPayloadAt;
  bool _isNavigating = false;
  bool _isCheckingPermission = false;
  bool _isImportingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
    unawaited(_checkCameraPermission(requestIfNeeded: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkCameraPermission());
    }
  }

  Future<void> _checkCameraPermission({bool requestIfNeeded = false}) async {
    if (_isCheckingPermission) {
      return;
    }
    _isCheckingPermission = true;
    try {
      var status = await Permission.camera.status;
      if (requestIfNeeded && status.isDenied) {
        status = await Permission.camera.request();
      }
      if (mounted) {
        setState(() => _permissionStatus = status);
      }
    } finally {
      _isCheckingPermission = false;
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = _permissionStatus ?? await Permission.camera.status;
    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();
      await _checkCameraPermission();
      return;
    }
    await _checkCameraPermission(requestIfNeeded: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCapture(BarcodeCapture capture) async {
    if (_isNavigating) {
      return;
    }
    final payloadWatch = Stopwatch()..start();
    final payload = _scannerService.firstUsablePayload(
      capture.barcodes.map((barcode) => barcode.rawValue),
    );
    payloadWatch.stop();
    debugPrint(
      'TurkQuishTiming qr_payload_extraction_ms='
      '${(payloadWatch.elapsedMicroseconds / 1000.0).toStringAsFixed(4)}',
    );
    if (payload == null) {
      return;
    }

    final now = DateTime.now();
    if (_lastPayload == payload &&
        _lastPayloadAt != null &&
        now.difference(_lastPayloadAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastPayload = payload;
    _lastPayloadAt = now;

    setState(() => _status = ScannerStatus.qrDetected);
    final validationWatch = Stopwatch()..start();
    final validation = UrlValidator.inspect(payload);
    validationWatch.stop();
    debugPrint(
      'TurkQuishTiming url_validation_ms='
      '${(validationWatch.elapsedMicroseconds / 1000.0).toStringAsFixed(4)}',
    );
    if (!validation.isValid) {
      setState(() => _status = ScannerStatus.invalidPayload);
      return;
    }

    await _routeUrl(validation.normalizedUrl!);
  }

  Future<void> _routeUrl(String url) async {
    _isNavigating = true;
    setState(
      () => _status = ref.read(settingsStoreProvider).quickScanMode
          ? ScannerStatus.submitting
          : ScannerStatus.readyForPreview,
    );
    await _controller.stop();
    if (!mounted) {
      return;
    }

    final settings = ref.read(settingsStoreProvider);
    await context.push(
      settings.quickScanMode ? '/analysis' : '/preview',
      extra: url,
    );
    if (mounted) {
      setState(() {
        _status = ScannerStatus.idle;
        _isNavigating = false;
      });
      await _controller.start();
    }
  }

  Future<void> _openManualInput() async {
    final url = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ManualUrlInputSheet(),
    );
    if (url != null) {
      await _routeUrl(url);
    }
  }

  Future<void> _importQrFromGallery() async {
    if (_isNavigating || _isImportingImage) {
      return;
    }
    final strings = AppStrings.of(context);
    setState(() {
      _isImportingImage = true;
      _status = ScannerStatus.detecting;
    });
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      final capture = await _controller.analyzeImage(
        image.path,
        formats: const [BarcodeFormat.qrCode],
      );
      if (capture == null) {
        _showSnackBar(strings.text('noQrInImage'));
        return;
      }
      await _handleCapture(capture);
    } on UnsupportedError {
      _showSnackBar(strings.text('qrImageUnsupported'));
    } on MobileScannerBarcodeException {
      _showSnackBar(strings.text('qrImageError'));
    } catch (_) {
      _showSnackBar(strings.text('qrImageError'));
    } finally {
      if (mounted) {
        setState(() {
          _isImportingImage = false;
          if (!_isNavigating) {
            _status = ScannerStatus.idle;
          }
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final permissionStatus = _permissionStatus;

    return Scaffold(
      body: SafeArea(
        child: permissionStatus == null
            ? const _PermissionChecking()
            : permissionStatus.isGranted
            ? _buildScanner()
            : _PermissionDenied(
                status: permissionStatus,
                onRetry: _requestCameraPermission,
              ),
      ),
    );
  }

  Widget _buildScanner() {
    final strings = AppStrings.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) => unawaited(_handleCapture(capture)),
        ),
        const _ScannerFrameOverlay(),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
            children: [
              _ToolbarButton(
                icon: Icons.history,
                tooltip: strings.text('history'),
                onPressed: () => context.push('/history'),
              ),
              const Spacer(),
              _ToolbarButton(
                icon: Icons.flashlight_on_outlined,
                tooltip: strings.text('torch'),
                onPressed: () => _controller.toggleTorch(),
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: Icons.cameraswitch_outlined,
                tooltip: strings.text('switchCamera'),
                onPressed: () => _controller.switchCamera(),
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: Icons.settings_outlined,
                tooltip: strings.text('settings'),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusPill(status: _status),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openManualInput,
                      icon: const Icon(Icons.keyboard_alt_outlined),
                      label: Text(strings.text('manualUrl')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: strings.text('qrFromGallery'),
                    onPressed: _isImportingImage ? null : _importQrFromGallery,
                    icon: _isImportingImage
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_library_outlined),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: strings.text('lastResult'),
                    onPressed: () => context.push('/history'),
                    icon: const Icon(Icons.manage_search_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PermissionChecking extends StatelessWidget {
  const _PermissionChecking();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied({required this.status, required this.onRetry});

  final PermissionStatus status;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final needsSettings = status.isPermanentlyDenied || status.isRestricted;
    final strings = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              strings.text('cameraPermissionRequired'),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              needsSettings
                  ? strings.text('cameraBlocked')
                  : strings.text('cameraPermissionRationale'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(
                needsSettings
                    ? Icons.settings_outlined
                    : Icons.camera_alt_outlined,
              ),
              label: Text(
                needsSettings
                    ? strings.text('openSettings')
                    : strings.text('allowCamera'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.46),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ScannerStatus status;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final (label, icon, color) = switch (status) {
      ScannerStatus.idle || ScannerStatus.detecting => (
        strings.text('scannerStatusPoint'),
        Icons.qr_code_scanner,
        AppColors.deepBlue,
      ),
      ScannerStatus.qrDetected => (
        strings.text('scannerStatusDetected'),
        Icons.qr_code_2,
        AppColors.cyan,
      ),
      ScannerStatus.invalidPayload => (
        strings.text('invalidUrl'),
        Icons.link_off,
        AppColors.dangerRed,
      ),
      ScannerStatus.readyForPreview => (
        strings.text('scannerStatusReady'),
        Icons.preview_outlined,
        AppColors.safeGreen,
      ),
      ScannerStatus.submitting => (
        strings.text('scannerStatusSubmitting'),
        Icons.cloud_upload_outlined,
        AppColors.cautionOrange,
      ),
      ScannerStatus.error => (
        strings.text('scannerStatusError'),
        Icons.error_outline,
        AppColors.dangerRed,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrameOverlay extends StatelessWidget {
  const _ScannerFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _ScannerFramePainter(), child: Container()),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.46);
    final frameSize = (size.shortestSide * 0.68).clamp(220.0, 340.0);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameSize,
      height: frameSize,
    );
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlay);

    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const corner = 42.0;
    for (final start in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      final isRight = start.dx > rect.center.dx;
      final isBottom = start.dy > rect.center.dy;
      canvas.drawLine(
        start,
        start.translate(isRight ? -corner : corner, 0),
        cornerPaint,
      );
      canvas.drawLine(
        start,
        start.translate(0, isBottom ? -corner : corner),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
