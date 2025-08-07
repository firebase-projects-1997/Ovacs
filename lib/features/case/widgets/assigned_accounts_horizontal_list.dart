import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/functions/show_snackbar.dart';
import '../../../data/models/assigned_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/assigned_accounts_provider.dart';

class AssignedAccountsHorizontalList extends StatefulWidget {
  final int caseId;
  final VoidCallback? onAddPressed;

  const AssignedAccountsHorizontalList({
    super.key,
    required this.caseId,
    this.onAddPressed,
  });

  @override
  State<AssignedAccountsHorizontalList> createState() =>
      _AssignedAccountsHorizontalListState();
}

class _AssignedAccountsHorizontalListState
    extends State<AssignedAccountsHorizontalList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignedAccountsProvider>().fetchAssignedAccounts(
        widget.caseId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Consumer<AssignedAccountsProvider>(
      builder: (context, provider, child) {
        if (provider.status == AssignedAccountsStatus.loading &&
            provider.assignedAccounts.isEmpty) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.status == AssignedAccountsStatus.error) {
          return SizedBox(
            height: 80,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.warning_2, color: Colors.red, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    localizations.failedToLoad,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () =>
                        provider.fetchAssignedAccounts(widget.caseId),
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.assignedAccounts.isEmpty) {
          return SizedBox(
            height: 80,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.user_minus,
                    color: AppColors.mediumGrey,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.noAccountsAssigned,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.assignedAccounts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final assignedAccount = provider.assignedAccounts[index];
              return _buildAssignedAccountCard(
                context,
                assignedAccount,
                provider,
                localizations,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAssignedAccountCard(
    BuildContext context,
    AssignedAccountModel assignedAccount,
    AssignedAccountsProvider provider,
    AppLocalizations localizations,
  ) {
    final account = assignedAccount.account;
    final isUpdating = provider.isAccountLoading(
      account.id,
      AssignedAccountAction.updateRole,
    );
    final isDeassigning = provider.isAccountLoading(
      account.id,
      AssignedAccountAction.deassign,
    );

    return RoundedContainer(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _getRoleColor(
                assignedAccount.role,
              ).withValues(alpha: 0.2),
              child: Icon(
                Iconsax.user,
                color: _getRoleColor(assignedAccount.role),
              ),
            ),
            // Account name
            Text(
              account.name ?? localizations.unknown,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            // Role
            Text(
              assignedAccount.role.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getRoleColor(assignedAccount.role),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Action buttons (only show on long press or tap)
            if (isUpdating || isDeassigning)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: _getRoleColor(assignedAccount.role),
                ),
              ),
          ],
        ),
      ),
      onTap: () => _showAccountActionsDialog(
        context,
        assignedAccount,
        provider,
        localizations,
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'diamond':
        return Colors.blue;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      default:
        return AppColors.mediumGrey;
    }
  }

  void _showAccountActionsDialog(
    BuildContext context,
    AssignedAccountModel assignedAccount,
    AssignedAccountsProvider provider,
    AppLocalizations localizations,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Account info header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getRoleColor(
                    assignedAccount.role,
                  ).withValues(alpha: 0.2),
                  child: Icon(
                    Iconsax.user,
                    color: _getRoleColor(assignedAccount.role),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignedAccount.account.name ?? 'Unknown Account',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Icon(
                            Iconsax.crown,
                            size: 14,
                            color: _getRoleColor(assignedAccount.role),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            assignedAccount.role.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _getRoleColor(assignedAccount.role),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showUpdateRoleDialog(context, assignedAccount, provider);
                    },
                    icon: const Icon(Iconsax.edit),
                    label: const Text('Update Role'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showDeassignDialog(context, assignedAccount, provider);
                    },
                    icon: const Icon(Iconsax.user_minus),
                    label: const Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateRoleDialog(
    BuildContext context,
    AssignedAccountModel assignedAccount,
    AssignedAccountsProvider provider,
  ) {
    String selectedRole = assignedAccount.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update role for ${assignedAccount.account.name ?? 'Unknown Account'}',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: provider.availableRoles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Icon(Iconsax.crown, size: 16, color: _getRoleColor(role)),
                      const SizedBox(width: 8),
                      Text(role.toUpperCase()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) selectedRole = value;
              },
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.updateAccountRole(
                accountId: assignedAccount.account.id,
                newRole: selectedRole,
              );

              if (context.mounted) {
                showAppSnackBar(
                  context,
                  success
                      ? 'Role updated successfully'
                      : provider.errorMessage ?? 'Failed to update role',
                  type: success ? SnackBarType.success : SnackBarType.error,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeassignDialog(
    BuildContext context,
    AssignedAccountModel assignedAccount,
    AssignedAccountsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assignment'),
        content: Text(
          'Are you sure you want to remove ${assignedAccount.account.name ?? 'this account'} from this case?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.deassignAccount(
                assignedAccount.account.id,
              );

              if (context.mounted) {
                showAppSnackBar(
                  context,
                  success
                      ? 'Account removed successfully'
                      : provider.errorMessage ?? 'Failed to remove account',
                  type: success ? SnackBarType.success : SnackBarType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
