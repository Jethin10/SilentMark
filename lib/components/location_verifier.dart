import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LocationVerifier extends StatefulWidget {
  final Function(Position) onVerified;
  const LocationVerifier({super.key, required this.onVerified});

  @override
  State<LocationVerifier> createState() => _LocationVerifierState();
}

class _LocationVerifierState extends State<LocationVerifier> {
  bool isLoading = false;
  String? error;

  Future<void> _verify() async {
    setState(() { isLoading = true; error = null; });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw "Permission denied";
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      widget.onVerified(position);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Icon(LucideIcons.mapPin, size: 32, color: Colors.indigo),
          const SizedBox(height: 8),
          const Text("Verify Location", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (isLoading) const CircularProgressIndicator()
          else ElevatedButton(onPressed: _verify, child: const Text("Check GPS")),
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
