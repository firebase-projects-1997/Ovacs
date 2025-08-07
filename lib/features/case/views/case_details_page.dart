import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/features/case/provider/case_details_provider.dart';
import 'package:new_ovacs/features/case/provider/cases_provider.dart';
import 'package:new_ovacs/features/case/providers/assigned_accounts_provider.dart';
import 'package:new_ovacs/features/connection/providers/connection_provider.dart';
import 'package:new_ovacs/features/message/views/messages_page.dart';
import 'package:new_ovacs/features/session/views/add_session_page.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../core/functions/is_dark_mode.dart';
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

class _CaseDetailsPageState extends State<CaseDetailsPage> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CaseDetailProvider>().fetchCaseDetail(widget.caseId);
      context.read<SessionsProvider>().fetchSessions(widget.caseId);
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
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => EditCasePage(
                        caseModel: context
                            .read<CaseDetailProvider>()
                            .caseModel!,
                      ),
                    ),
                  );
                  if (updated == true) {
                    context.read<CaseDetailProvider>().fetchCaseDetail(
                      widget.caseId,
                    );
                  }
                  break;
                case 'delete':
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

                  if (confirmed == true) {
                    final success = await context
                        .read<CaseDetailProvider>()
                        .deleteCase(widget.caseId);
                    if (success) {
                      context.read<CasesProvider>().fetchCases();
                      Navigator.of(context).pop();
                    } else {
                      showAppSnackBar(
                        context,
                        context.read<CaseDetailProvider>().errorMessage ??
                            AppLocalizations.of(context)!.errorDeletingCase,
                      );
                    }
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
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
            ],
          ),
        ],
      ),

      // Body with Consumer to rebuild when provider changes
      body: Consumer<CaseDetailProvider>(
        builder: (context, value, _) {
          if (value.status == CaseDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (value.errorMessage != null) {
            return Center(child: Text(value.errorMessage ?? ''));
          } else {
            if (value.caseModel == null) return SizedBox.shrink();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.caseWord} ${value.caseModel?.id}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  RoundedContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoColumn(
                          label: AppLocalizations.of(context)!.caseName,
                          value: value.caseModel?.title ?? '',
                        ),
                        const SizedBox(height: 16),
                        _InfoColumn(
                          label: AppLocalizations.of(context)!.description,
                          value: value.caseModel?.description ?? '',
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
                                        clientId: value.caseModel!.clientId,
                                      ),
                                    ),
                                  );
                                },
                                child: _InfoColumn(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.clientName,
                                  value: value.caseModel?.clientName ?? '',
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
                                    value.caseModel?.date
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.assignedAccounts,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      RoundedContainer(
                        onTap: () => _showAssignAccountDialog(context),
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
                    onAddPressed: () => _showAssignAccountDialog(context),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.sessions,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      RoundedContainer(
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  Consumer<SessionsProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
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
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
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
          }
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
        height: 400,
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
                        role: selectedRole,
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
