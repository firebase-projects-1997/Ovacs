import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import '../../features/case/provider/cases_provider.dart';
import '../../l10n/app_localizations.dart';

class WorkspaceBanner extends StatelessWidget {
  const WorkspaceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, workspaceProvider, child) {
        if (workspaceProvider.isPersonalMode) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context)!;

        return Padding(
          padding: EdgeInsetsGeometry.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.profile_2user,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.viewingWorkspaceOf(
                      workspaceProvider.activeAccountName ?? '',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await workspaceProvider.switchToPersonalWorkspace();
                    // Refresh cases to show user's own cases after closing workspace
                    if (context.mounted) {
                      context.read<CasesProvider>().fetchCases();
                    }
                  },
                  icon: Icon(
                    Iconsax.close_circle,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  label: Text(
                    l10n.close,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
