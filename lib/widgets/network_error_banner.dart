import 'package:flutter/material.dart';

class NetworkErrorBanner extends StatelessWidget {
  final String message;
  final bool isOffline;
  final VoidCallback onRetry;
  final VoidCallback? onDismiss;

  const NetworkErrorBanner({
    super.key,
    required this.message,
    this.isOffline = false,
    required this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOffline ? Colors.amber.shade900 : Colors.red.shade800,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.cloud_off : Icons.wifi_off,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: const Text('Retry'),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 18),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
