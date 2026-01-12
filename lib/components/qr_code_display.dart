import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../utils/totp_utils.dart';

class QRCodeDisplay extends StatefulWidget {
  final String sessionId;
  final String secretKey;
  const QRCodeDisplay({super.key, required this.sessionId, required this.secretKey});

  @override
  State<QRCodeDisplay> createState() => _QRCodeDisplayState();
}

class _QRCodeDisplayState extends State<QRCodeDisplay> {
  late String currentCode;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshCode();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _refreshCode());
  }

  void _refreshCode() {
    setState(() {
      currentCode = TotpUtils.generateTOTP(widget.secretKey);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.indigo.withOpacity(0.1), width: 4),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
          ),
          child: QrImageView(
            data: "FLASH:${widget.sessionId}:$currentCode",
            version: QrVersions.auto,
            size: 250.0,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.indigo),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock, size: 16, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                "Secure Token: $currentCode",
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.indigo, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
