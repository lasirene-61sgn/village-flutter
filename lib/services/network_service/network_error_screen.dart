// lib/service/network_service/network_overlay.dart
import 'package:flutter/material.dart';

class NetworkOverlay extends StatelessWidget {
  const NetworkOverlay({super.key});

  @override
  Widget build(BuildContext context) {

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        color: Colors.red.shade700,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.signal_wifi_off, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                "You are offline. Some features may not work.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  // Prevent any inherited text style issues
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade300,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
