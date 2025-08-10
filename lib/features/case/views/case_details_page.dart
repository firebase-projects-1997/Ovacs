import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/features/case/providers/case_details_provider.dart';
import 'package:new_ovacs/features/case/providers/cases_provider.dart';
import 'package:new_ovacs/features/case/providers/assigned_accounts_provider.dart';
import 'package:new_ovacs/core/widgets/state_widgets.dart';
import 'package:new_ovacs/features/connection/providers/connection_provider.dart';
import 'package:new_ovacs/features/message/views/messages_page.dart';
import 'package:new_ovacs/features/session/views/add_session_page.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';

import '../../../common/providers/workspace_provider.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../common/widgets/permission_guard.dart';
import '../../../core/functions/is_dark_mode.dart';
import '../../../core/enums/permission_resource.dart';
import '../../../core/enums/permission_action.dart';
import '../../../core/mixins/permission_mixin.dart';
import '../../client/views/client_info_page.dart';
import '../../session/providers/sessions_provider.dart';
import '../../session/views/session_details_page.dart';
import '../../session/widgets/session_card.dart';
import '../widgets/assigned_accounts_horizontal_list.dart';
import 'edit_case_page.dart';
import '../../../l10n/app_localizations.dart';

class CaseDetailsPage extends StatefulWidget {
  final int caseId;
  const CaseDetailsPage({super.key, required this.caseId});

  @override
  State<CaseDetailsPage> createState() => _CaseDetailsPageState();
}

class _CaseDetailsPageState extends State<CaseDetailsPage>
    with PermissionMixin {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (mounted) {
        final workspaceProvider = context.read<WorkspaceProvider>();
        final filters = workspaceProvider.getWorkspaceQueryParams();

        // Load permissions for current workspace context
        await loadPermissions(forceRefresh: true);

        if (mounted) {
          // Initialize permissions for the case detail provider
          final caseDetailProvider = context.read<CaseDetailProvider>();
          caseDetailProvider.initializePermissions(context);

          // Initialize and load assigned accounts
          final assignedAccountsProvider = context
              .read<AssignedAccountsProvider>();
          assignedAccountsProvider.initializePermissions(context);

          // Load all data
          caseDetailProvider.fetchCaseDetail(widget.caseId);
          assignedAccountsProvider.fetchAssignedAccounts(widget.caseId);
          context.read<SessionsProvider>().fetchSessions(
            widget.caseId,
            filters: filters.isNotEmpty ? filters : null,
          );
        }
      }
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final provider = context.read<SessionsProvider>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !provider.isLoadingMore &&
          !provider.isLoading &&
          provider.hasMoreData) {
        provider.fetchMoreSessions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Consumer<CaseDetailProvider>(
          builder: (context, value, _) {
            return Text(
              AppLocalizations.of(context)!.caseInformation(widget.caseId),
              style: Theme.of(context).textTheme.titleLarge,
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Iconsax.more_circle),
            onSelected: (selectedValue) async {
              switch (selectedValue) {
                case 'edit':
                  await executeWithPermissionInSpaceContext(
                    PermissionResource.case_,
                    PermissionAction.update,
                    () async {
                      final caseDetailProvider = context
                          .read<CaseDetailProvider>();
                      final navigator = Navigator.of(context);

                      final updated = await navigator.push<bool>(
                        MaterialPageRoute(
                          builder: (_) => EditCasePage(
                            caseModel: caseDetailProvider.caseModel!,
                          ),
                        ),
                      );
                      if (updated == true && mounted) {
                        caseDetailProvider.fetchCaseDetail(widget.caseId);
                      }
                    },
                  );
                  break;
                case 'delete':
                  await executeWithPermissionInSpaceContext(
                    PermissionResource.case_,
                    PermissionAction.delete,
                    () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.confirmDeletion,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.areYouSureYouWantToDeleteThisCase,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx, true);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.delete,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && mounted) {
                        final caseDetailProvider = context
                            .read<CaseDetailProvider>();
                        final casesProvider = context.read<CasesProvider>();
                        final navigator = Navigator.of(context);
                        final localizations = AppLocalizations.of(context)!;

                        final success = await caseDetailProvider.deleteCase(
                          widget.caseId,
                        );
                        if (success && mounted) {
                          casesProvider.fetchCases();
                          navigator.pop();
                        } else if (mounted) {
                          showAppSnackBar(
                            context,
                            caseDetailProvider.errorMessage ??
                                localizations.errorDeletingCase,
                          );
                        }
                      }
                    },
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                // Always show menu items, permission check happens in onSelected
                PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Iconsax.edit),
                    title: Text(AppLocalizations.of(context)!.edit),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Iconsax.trash, color: Colors.red),
                    title: Text(AppLocalizations.of(context)!.delete),
                  ),
                ),
              ];
            },
          ),
        ],
      ),

      // Body with Consumer to rebuild when provider changes
      body: Consumer<CaseDetailProvider>(
        builder: (context, provider, _) {
          return StateBuilder(
            state: provider.state,
            onInitial: () =>
                const Center(child: Text('Ready to load case details')),
            onLoading: () => const StandardLoadingIndicator(
              message: 'Loading case details...',
            ),
            onSuccess: () {
              if (provider.caseModel == null) {
                return const StandardEmptyWidget(
                  title: 'No Case Data',
                  subtitle: 'Case details are not available',
                  icon: Icons.folder_open,
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.caseWord} ${provider.caseModel?.id}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    RoundedContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoColumn(
                            label: AppLocalizations.of(context)!.caseName,
                            value: provider.caseModel?.title ?? '',
                          ),
                          const SizedBox(height: 16),
                          _InfoColumn(
                            label: AppLocalizations.of(context)!.description,
                            value: provider.caseModel?.description ?? '',
                          ),

                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    navigatorKey.currentState!.push(
                                      MaterialPageRoute(
                                        builder: (context) => ClientDetailsPage(
                                          clientId:
                                              provider.caseModel!.clientId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _InfoColumn(
                                    label: AppLocalizations.of(
                                      context,
                                    )!.clientName,
                                    value: provider.caseModel?.clientName ?? '',
                                    isLink: true,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _InfoColumn(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.appearInCourtOn,
                                  value:
                                      provider.caseModel?.date
                                          .toIso8601String()
                                          .split('T')
                                          .first ??
                                      '',
                                  isLink: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        navigatorKey.currentState!.push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagesPage(caseId: widget.caseId),
                          ),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.messages),
                    ),
                    const SizedBox(height: 20),
                    // Only show assigned accounts section when in personal workspace
                    Consumer<WorkspaceProvider>(
                      builder: (context, workspaceProvider, child) {
                        if (workspaceProvider.isConnectionMode) {
                          // Don't show assigned accounts when viewing another account's cases
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  localizations.assignedAccounts,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                RoundedContainer(
                                  onTap: () =>
                                      _showAssignAccountDialog(context),
                                  child: Icon(
                                    Iconsax.add,
                                    color: isDarkMode(context)
                                        ? AppColors.pureWhite
                                        : AppColors.charcoalGrey,
                                  ),
                                ),
                              ],
                            ),
                            AssignedAccountsHorizontalList(
                              caseId: widget.caseId,
                              onAddPressed: () =>
                                  _showAssignAccountDialog(context),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.sessions,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        // Show add session button based on permissions
                        PermissionGuard(
                          resource: PermissionResource.session,
                          action: PermissionAction.create,
                          child: RoundedContainer(
                            onTap: () {
                              navigatorKey.currentState!.push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddSessionPage(caseId: widget.caseId),
                                ),
                              );
                            },
                            child: Icon(
                              Iconsax.add,
                              color: isDarkMode(context)
                                  ? AppColors.pureWhite
                                  : AppColors.charcoalGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Search field for sessions
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Search sessions by title...',
                          prefixIcon: const Icon(Iconsax.search_normal),
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.close_circle),
                            onPressed: () {
                              // Clear search and refresh sessions
                              context.read<SessionsProvider>().fetchSessions(
                                widget.caseId,
                              );
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.mediumGrey.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.mediumGrey.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.pureWhite,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.trim().isEmpty) {
                            // Clear search when input is empty
                            context.read<SessionsProvider>().fetchSessions(
                              widget.caseId,
                            );
                          } else {
                            // Search by session title
                            final filters = <String, dynamic>{
                              'search': value.trim(),
                            };
                            context.read<SessionsProvider>().fetchSessions(
                              widget.caseId,
                              filters: filters,
                            );
                          }
                        },
                      ),
                    ),
                    Consumer<SessionsProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (provider.errorMessage != null) {
                          return Center(child: Text(provider.errorMessage!));
                        } else if (provider.sessions.isEmpty) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noSessionsAvailable,
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: _scrollController,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // because inside scroll view
                          itemCount:
                              provider.sessions.length +
                              (provider.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index == provider.sessions.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final session = provider.sessions[index];
                            return SessionCard(
                              sessionModel: session,
                              onTap: () {
                                navigatorKey.currentState!.push(
                                  MaterialPageRoute(
                                    builder: (context) => SessionDetailsPage(
                                      sessionId: session.id,
                                      caseId: widget.caseId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            onError: (error) => StandardErrorWidget(
              message: error,
              onRetry: () async {
                // Reload permissions first, then fetch case details
                await loadPermissions(forceRefresh: true);
                if (mounted) {
                  // Re-initialize permissions for the providers
                  provider.initializePermissions(context);
                  final assignedAccountsProvider = context
                      .read<AssignedAccountsProvider>();
                  assignedAccountsProvider.initializePermissions(context);

                  // Reload all data
                  provider.fetchCaseDetail(widget.caseId);
                  assignedAccountsProvider.fetchAssignedAccounts(widget.caseId);
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showAssignAccountDialog(BuildContext context) {
    final assignedProvider = context.read<AssignedAccountsProvider>();
    final connectionProvider = context.read<ConnectionProvider>();

    // Ensure followers are loaded
    if (connectionProvider.followers.isEmpty &&
        !connectionProvider.isLoadingFollowers) {
      connectionProvider.fetchFollowers();
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => _AssignAccountDialog(
        assignedProvider: assignedProvider,
        connectionProvider: connectionProvider,
        caseId: widget.caseId,
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: isLink ? Theme.of(context).primaryColor : null,
              decoration: isLink
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: isLink ? Theme.of(context).primaryColor : null,
            ),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _AssignAccountDialog extends StatefulWidget {
  final AssignedAccountsProvider assignedProvider;
  final ConnectionProvider connectionProvider;
  final int caseId;

  const _AssignAccountDialog({
    required this.assignedProvider,
    required this.connectionProvider,
    required this.caseId,
  });

  @override
  State<_AssignAccountDialog> createState() => _AssignAccountDialogState();
}

class _AssignAccountDialogState extends State<_AssignAccountDialog> {
  String selectedRole = 'gold';
  int? selectedAccountId;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Iconsax.user_add),
          const SizedBox(width: 8),
          Text(localizations.assignAccount),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a follower to assign to this case:'),
            const SizedBox(height: 16),

            // Search field
            TextField(
              decoration: InputDecoration(
                labelText: localizations.searchFollowers,
                hintText: localizations.typeToSearch,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Iconsax.search_normal),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 16),

            // Role selection
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: localizations.role,
                // border: OutlineInputBorder(),
                prefixIcon: const Icon(Iconsax.crown),
              ),
              items: widget.assignedProvider.availableRoles.map((role) {
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
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Followers list
            Expanded(
              child: Consumer<ConnectionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingFollowers) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.followersfailure != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.warning_2, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(localizations.failedToLoadFollowers),
                          TextButton(
                            onPressed: () => provider.fetchFollowers(),
                            child: Text(localizations.retry),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.followers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.user_minus,
                            color: AppColors.mediumGrey,
                          ),
                          const SizedBox(height: 8),
                          Text(localizations.noFollowersAvailable),
                        ],
                      ),
                    );
                  }

                  // Filter followers based on search and already assigned
                  final filteredFollowers = provider.followers.where((
                    follower,
                  ) {
                    final matchesSearch =
                        searchQuery.isEmpty ||
                        follower.name.toLowerCase().contains(searchQuery);
                    final notAlreadyAssigned = !widget.assignedProvider
                        .isAccountAssigned(follower.id);
                    return matchesSearch && notAlreadyAssigned;
                  }).toList();

                  if (filteredFollowers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.search_normal,
                            color: AppColors.mediumGrey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchQuery.isEmpty
                                ? localizations.allFollowersAlreadyAssigned
                                : localizations.noFollowersMatchSearch,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredFollowers.length,
                    itemBuilder: (context, index) {
                      final follower = filteredFollowers[index];
                      final isSelected = selectedAccountId == follower.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.2)
                              : AppColors.mediumGrey.withValues(alpha: 0.2),
                          child: Icon(
                            Iconsax.user,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : AppColors.mediumGrey,
                          ),
                        ),
                        title: Text(follower.name),
                        subtitle: Text('ID: ${follower.id}'),
                        trailing: isSelected
                            ? Icon(
                                Iconsax.tick_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedAccountId = isSelected ? null : follower.id;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: selectedAccountId == null
              ? null
              : () async {
                  Navigator.of(context).pop();

                  final success = await widget.assignedProvider
                      .assignAccountToCase(
                        accountId: selectedAccountId!,
                        role: selectedRole
                            .toLowerCase(), // Convert to lowercase for backend
                      );

                  if (context.mounted) {
                    showAppSnackBar(
                      context,
                      success
                          ? localizations.accountAssignedSuccessfully
                          : widget.assignedProvider.errorMessage ??
                                localizations.failedToAssignAccount,
                      type: success ? SnackBarType.success : SnackBarType.error,
                    );
                  }
                },
          child: Text(localizations.assign),
        ),
      ],
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
        return Colors.grey;
    }
  }
}
