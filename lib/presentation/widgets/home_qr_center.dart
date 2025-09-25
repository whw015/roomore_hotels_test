import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../screens/qr_scanner_screen.dart';

class HomeQrCenter extends StatelessWidget {
  const HomeQrCenter({
    super.key,
    required this.message,
    required this.controller,
    required this.onConfirm,
    this.isProcessing = false,
  });

  final String? message;

  final TextEditingController controller;
  final Future<void> Function(String code) onConfirm;
  final bool isProcessing;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Icon Button → qr_scanner_screen.dart
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                iconSize: 60,
                color: Colors.white,
                onPressed: () async {
                  final scannedCode = await Navigator.of(context).push<String>(
                    MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                  );
                  final code = scannedCode?.trim() ?? '';
                  if (code.isEmpty) {
                    return;
                  }
                  controller.text = code;
                  await onConfirm(code);
                },
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: tr('home.scan_qr'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr('home.scan_hotel_qr'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            // Text(
            //   tr('home.or_enter_code_manually'),
            //   textAlign: TextAlign.center,
            //   style: const TextStyle(
            //     color: AppColors.purple,
            //     fontWeight: FontWeight.w700,
            //   ),
            // ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              enabled: !isProcessing,
              decoration: InputDecoration(
                hintText: tr('home.enter_hotel_code'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) async {
                await onConfirm(value);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      await onConfirm(controller.text);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      tr('common.confirm'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _withAlpha(AppColors.purple, 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _withAlpha(AppColors.purple, 0.12)),
                ),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _withAlpha(AppColors.purple, 0.9)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===== Helper (no withOpacity) =====
Color _withAlpha(Color c, double opacity01) {
  final a = (255 * opacity01).round().clamp(0, 255);
  return c.withAlpha(a);
}
