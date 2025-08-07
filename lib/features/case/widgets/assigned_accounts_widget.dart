import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/functions/show_snackbar.dart';
import '../../../data/models/assigned_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/assigned_accounts_provider.dart';

class AssignedAccountsWidget extends StatefulWidget {
  final int caseId;
  final bool showAddButton;
  final VoidCallback? onAddPressed;

  const AssignedAccountsWidget({
    super.key,
    required this.caseId,
    this.showAddButton = true,
    this.onAddPressed,
  });

  @override
  State<AssignedAccountsWidget> createState() => _AssignedAccountsWidgetState();
}

class _AssignedAccountsWidgetState extends State<AssignedAccountsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignedAccountsProvider>().fetchAssignedAccounts(widget.caseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Consumer<AssignedAccountsProvider>(
      builder: (context, provider, child) {
        return RoundedContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Iconsax.people, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Assigned Accounts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (widget.showAddButton)
                    IconButton(
                      onPressed: widget.onAddPressed ?? () => _showAssignDialog(context),
                      icon: const Icon(Iconsax.add_circle),
                      tooltip: 'Assign Account',
                    ),
                  IconButton(
                    onPressed: provider.isLoading ? null : () => provider.refresh(),
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Iconsax.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Content
              if (provider.status == AssignedAccountsStatus.loading && provider.assignedAccounts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.status == AssignedAccountsStatus.error)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Iconsax.warning_2, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage ?? 'Failed to load assigned accounts',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => provider.fetchAssignedAccounts(widget.caseId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (provider.assignedAccounts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Iconsax.user_minus, color: AppColors.mediumGrey, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'No accounts assigned to this case',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.assignedAccounts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final assignedAccount = provider.assignedAccounts[index];
                    return _buildAssignedAccountCard(context, assignedAccount, provider);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignedAccountCard(
    BuildContext context,
    AssignedAccountModel assignedAccount,
    AssignedAccountsProvider provider,
  ) {
    final account = assignedAccount.account;
    final isUpdating = provider.isAccountLoading(account.id, AssignedAccountAction.updateRole);
    final isDeassigning = provider.isAccountLoading(account.id, AssignedAccountAction.deassign);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Account info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name ?? 'Unknown Account',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (account.owner?.name != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      account.owner!.name!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getRoleColor(assignedAccount.role),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Update role button
                IconButton(
                  onPressed: isUpdating || isDeassigning
                      ? null
                      : () => _showUpdateRoleDialog(context, assignedAccount),
                  icon: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Iconsax.edit, size: 18),
                  tooltip: 'Update Role',
                ),

                // Deassign button
                IconButton(
                  onPressed: isUpdating || isDeassigning
                      ? null
                      : () => _showDeassignDialog(context, assignedAccount),
                  icon: isDeassigning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Iconsax.user_minus, size: 18, color: Colors.red),
                  tooltip: 'Remove Assignment',
                ),
              ],
            ),
          ],
        ),
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

  void _showAssignDialog(BuildContext context) {
    // This would typically open a dialog to select an account and role
    // For now, we'll show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Account'),
        content: const Text('Account assignment dialog would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUpdateRoleDialog(BuildContext context, AssignedAccountModel assignedAccount) {
    final provider = context.read<AssignedAccountsProvider>();
    String selectedRole = assignedAccount.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update role for ${assignedAccount.account.name ?? 'Unknown Account'}'),
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
                  success ? 'Role updated successfully' : provider.errorMessage ?? 'Failed to update role',
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

  void _showDeassignDialog(BuildContext context, AssignedAccountModel assignedAccount) {
    final provider = context.read<AssignedAccountsProvider>();

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
              final success = await provider.deassignAccount(assignedAccount.account.id);
              
              if (context.mounted) {
                showAppSnackBar(
                  context,
                  success ? 'Account removed successfully' : provider.errorMessage ?? 'Failed to remove account',
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
