import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:easy_localization/easy_localization.dart';

class QrScannerScreen extends StatefulWidget {
  static const routeName = '/qr-scanner';
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;

  bool _hasPermission = false;
  bool _permissionDenied = false;
  bool _handlingScan = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission(); // لا نلمس context هنا
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _hasPermission = status.isGranted;
      _permissionDenied = status.isPermanentlyDenied || status.isDenied;
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    // دعم hot-reload على أندرويد
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null) return;
    if (state == AppLifecycleState.paused) {
      c.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      c.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;

    controller.scannedDataStream.listen((scan) async {
      final raw = scan.code;
      if (raw == null || _handlingScan) return;

      final normalized = _extractHotelCode(raw);
      if (normalized == null) return;
      if (normalized.isEmpty) return;

      _handlingScan = true;
      try {
        await _controller?.pauseCamera();
        if (!mounted) return;
        Navigator.of(context).pop(normalized);
      } catch (_) {
        _handlingScan = false;
      }
    });
  }

  String? _extractHotelCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      final byQuery = uri.queryParameters['hotelCode'] ?? uri.queryParameters['code'];
      if (byQuery != null && byQuery.trim().isNotEmpty) {
        return byQuery.trim();
      }
      if (uri.pathSegments.isNotEmpty) {
        final candidate = uri.pathSegments.last.trim();
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }
    }
    return trimmed;
  }

  Widget _buildQrView(BuildContext context) {
    final cutOut = MediaQuery.of(context).size.width * 0.72;
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).colorScheme.primary,
        borderRadius: 12,
        borderLength: 30,
        borderWidth: 6,
        cutOutSize: cutOut,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ملاحظة: qr_code_scanner_plus يصرّح أن الـ controller يتخلّص ذاتيًا عند إزالة الـ QRView
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      // لا نستخدم onPopInvoked لتفادي تحذيرات deprecation على إصدارات لاحقة
      child: Scaffold(
        appBar: AppBar(
          title: Text('qr.scan_title'.tr()),
          actions: [
            IconButton(
              tooltip: 'qr.toggle_flash'.tr(),
              onPressed: () async {
                // لا نستخدم context بعد await
                await _controller?.toggleFlash();
                if (!mounted) return;
                setState(() {});
              },
              icon: FutureBuilder<bool?>(
                future: _controller?.getFlashStatus(),
                builder: (_, snap) => Icon(
                  (snap.data ?? false) ? Icons.flash_on : Icons.flash_off,
                ),
              ),
            ),
            IconButton(
              tooltip: 'qr.switch_camera'.tr(),
              onPressed: () async {
                await _controller?.flipCamera();
                if (!mounted) return;
                setState(() {});
              },
              icon: const Icon(Icons.cameraswitch),
            ),
          ],
        ),
        body: !_hasPermission
            ? (_permissionDenied
                  ? _PermissionBlocked(onOpenSettings: openAppSettings)
                  : const _PermissionLoading())
            : Stack(
                children: [
                  Positioned.fill(child: _buildQrView(context)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'qr.align_code_hint'.tr(),
                        textAlign: TextAlign.center,
                        // نتجنب withOpacity (deprecated على SDKs أحدث) ونستخدم withAlpha
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha((0.90 * 255).round()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PermissionLoading extends StatelessWidget {
  const _PermissionLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _PermissionBlocked extends StatelessWidget {
  final Future<bool> Function() onOpenSettings;
  const _PermissionBlocked({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('qr.permission_explainer'.tr(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onOpenSettings(),
              child: Text('qr.open_settings'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
