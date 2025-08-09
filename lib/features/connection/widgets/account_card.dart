import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import '../../../common/providers/permission_provider.dart';
import '../../../common/providers/workspace_provider.dart';
import '../../../data/models/space_account_model.dart';
import '../../../l10n/app_localizations.dart';

class AccountCard extends StatelessWidget {
  final SpaceAccountModel account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RoundedContainer(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.2),
          child: Icon(Iconsax.user, color: Theme.of(context).primaryColor),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(account.name),
        ),
        trailing: Text(l10n.idWithValue(account.id.toString())),
        subtitle: account.canSwitchTo
            ? ElevatedButton(
                onPressed: () async {
                  final workspaceProvider = context.read<WorkspaceProvider>();
                  final permissionProvider = context.read<PermissionProvider>();

                  // Switch workspace
                  await workspaceProvider.switchToConnectionWorkspace(account);

                  // Refresh permissions for the new workspace
                  await permissionProvider.fetchPermissions(
                    spaceId: account.id,
                    forceRefresh: true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.switchToWorkspace),
              )
            : null,
      ),
    );
  }
}
