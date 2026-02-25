import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';

class QrScanScreen extends StatefulWidget {
  final String title;
  final String expectedPayload;

  const QrScanScreen({
    super.key,
    required this.title,
    required this.expectedPayload,
  });

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final raw = barcode.rawValue;
      if (raw != null) {
        _scanned = true;
        _controller.stop();
        if (raw == widget.expectedPayload) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Geçersiz QR kodu!'),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _scanned = false;
              _controller.start();
            }
          });
        }
        break;
      }
    }
  }

  /// Demo mod — emülatörde kamera olmayabilir, bu buton ile simüle et
  void _simulateScan() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Overlay with scanner frame
          Column(
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryGreen, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'QR\'ı çerçeve içine al',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Demo button at the bottom
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Emülatörde kamera QR okuma çalışmayabilir.',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _simulateScan,
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: Text('Demo: QR Okuma Simüle Et'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: AppTheme.darkNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
