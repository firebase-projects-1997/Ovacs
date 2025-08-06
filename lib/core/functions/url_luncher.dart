import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

Future<void> launchGivenUrl(BuildContext context, String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.thisUrlCantLaunched),
        ),
      );
    }
  }
}
