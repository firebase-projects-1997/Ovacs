import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Widget to display server error messages with helpful information
class ServerErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showContactSupport;

  const ServerErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.showContactSupport = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPermissionError =
        message.contains("permission") ||
        message.contains("Permission") ||
        message.contains("unhashable");

    final isServerError =
        message.contains("Server") ||
        message.contains("configuration") ||
        message.contains("TypeError");

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPermissionError ? Iconsax.shield_cross : Iconsax.warning_2,
              size: 48,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),

          const SizedBox(height: 24),

          // Error Title
          Text(
            isPermissionError
                ? 'Permission System Issue'
                : isServerError
                ? 'Server Error'
                : 'Something Went Wrong',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Error Message
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onRetry != null) ...[
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Iconsax.refresh),
                  label: const Text('Try Again'),
                ),
                if (showContactSupport || isPermissionError || isServerError)
                  const SizedBox(width: 12),
              ],

              if (showContactSupport || isPermissionError || isServerError)
                OutlinedButton.icon(
                  onPressed: () => _showContactSupportDialog(context),
                  icon: const Icon(Iconsax.message),
                  label: const Text('Contact Support'),
                ),
            ],
          ),

          if (isPermissionError || isServerError) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPermissionError
                          ? 'This is a temporary server issue. Our team has been notified.'
                          : 'The server is experiencing technical difficulties. Please try again in a few minutes.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If this issue persists, please contact our support team with the following information:',
            ),
            SizedBox(height: 12),
            Text('• What you were trying to do'),
            Text('• When the error occurred'),
            Text('• Any steps that led to this error'),
            SizedBox(height: 12),
            Text('Support Email: support@ovacs.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// A simplified error widget for smaller spaces
class CompactServerErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CompactServerErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.warning_2,
                size: 20,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Iconsax.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
