import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/permission_resource.dart';
import '../../../core/enums/permission_action.dart';
import '../../../core/enums/document_security_level.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/config/permission_config.dart';
import '../../../common/widgets/permission_guard.dart';
import '../../../core/mixins/permission_mixin.dart';
import '../../../data/models/document_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/document_detail_provider.dart';
import '../providers/documents_provider.dart';
import '../providers/groups_provider.dart';

class DocumentDetailsPage extends StatefulWidget {
  final int documentId;
  final int? spaceId;

  const DocumentDetailsPage({
    super.key,
    required this.documentId,
    this.spaceId,
  });

  @override
  State<DocumentDetailsPage> createState() => _DocumentDetailsPageState();
}

class _DocumentDetailsPageState extends State<DocumentDetailsPage>
    with PermissionMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (mounted) {
        // Load permissions for specific space context if provided
        await loadPermissionsForContext(
          spaceId: widget.spaceId,
          forceRefresh: true,
        );

        if (mounted) {
          context.read<DocumentDetailProvider>().fetchDocumentDetail(
            widget.documentId,
          );
        }
      }
    });
  }

  String _formatFileSize(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(2)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat.yMMMd().add_jm().format(date);
    } catch (_) {
      return isoDate;
    }
  }

  Color _getSecurityLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'red':
        return AppColors.red;
      case 'yellow':
        return AppColors.gold;
      case 'green':
        return AppColors.green;
      default:
        return AppColors.mediumGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.documentDetails),
        actions: [
          Consumer<DocumentDetailProvider>(
            builder: (context, provider, child) {
              if (provider.document == null) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await executeWithPermissionInSpaceContext(
                      PermissionResource.document,
                      PermissionAction.update,
                      () async => _showEditDialog(
                        context,
                        provider.document!,
                        provider,
                      ),
                    );
                  } else if (value == 'delete') {
                    await executeWithPermissionInSpaceContext(
                      PermissionResource.document,
                      PermissionAction.delete,
                      () async => _showDeleteDialog(
                        context,
                        provider.document!,
                        provider,
                      ),
                    );
                  } else if (value == 'move') {
                    await executeWithPermissionInSpaceContext(
                      PermissionResource.documentGroup,
                      PermissionAction.update,
                      () async => _showMoveToGroupDialog(
                        context,
                        provider.document!,
                        provider,
                      ),
                    );
                  }
                },
                itemBuilder: (context) {
                  return [
                    // Always show menu items, permission check happens in onSelected
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Iconsax.edit),
                          const SizedBox(width: 8),
                          Text(l10n.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'move',
                      child: Row(
                        children: [
                          const Icon(Iconsax.folder_2),
                          const SizedBox(width: 8),
                          Text(l10n.moveToGroup),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Iconsax.trash, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            l10n.delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                icon: const Icon(Iconsax.more_circle),
              );
            },
          ),
        ],
      ),
      body: Consumer<DocumentDetailProvider>(
        builder: (context, provider, child) {
          return switch (provider.status) {
            DocumentDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            DocumentDetailStatus.error => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? l10n.errorOccurred,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.fetchDocumentDetail(widget.documentId);
                    },
                    icon: const Icon(Iconsax.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            DocumentDetailStatus.loaded => _buildDocumentDetails(
              context,
              provider.document!,
              l10n,
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildDocumentDetails(
    BuildContext context,
    DocumentModel document,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File Name Section
          RoundedContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.document,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        document.fileName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  l10n.fileSize,
                  _formatFileSize(document.fileSize),
                ),
                _buildInfoRow(
                  l10n.securityLevel,
                  document.securityLevel.toUpperCase(),
                  valueColor: _getSecurityLevelColor(document.securityLevel),
                ),
                _buildInfoRow(l10n.uploadedAt, _formatDate(document.createdAt)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Context Information
          if (document.clientName.isNotEmpty ||
              document.caseTitle != null ||
              document.sessionTitle != null ||
              document.groupName != null) ...[
            RoundedContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.contextInformation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (document.clientName.isNotEmpty)
                    _buildInfoRow(l10n.clients, document.clientName),
                  if (document.caseTitle != null)
                    _buildInfoRow(l10n.case_, document.caseTitle!),
                  if (document.sessionTitle != null)
                    _buildInfoRow(l10n.session, document.sessionTitle!),
                  if (document.groupName != null)
                    _buildInfoRow(l10n.groupName, document.groupName!),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          RoundedContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.actions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DocumentSecurityGuard(
                        action: PermissionAction.read,
                        securityLevel: DocumentSecurityLevel.fromString(
                          document.securityLevel,
                        ),
                        fallback: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "You don't have permission to view this document",
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Iconsax.eye),
                          label: Text(l10n.view),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<DocumentsProvider>().viewFile(
                              'https://ovacs.com/backend${document.secureViewUrl}',
                              document.fileName,
                            );
                          },
                          icon: const Icon(Iconsax.eye),
                          label: Text(l10n.view),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<DocumentsProvider>(
                        builder: (context, docProvider, child) {
                          final isDownloading = docProvider
                              .isDocumentDownloading(document.id);

                          return DocumentSecurityGuard(
                            action: PermissionAction.read,
                            securityLevel: DocumentSecurityLevel.fromString(
                              document.securityLevel,
                            ),
                            fallback: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "You don't have permission to download this document",
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Iconsax.arrow_circle_down),
                              label: Text(l10n.download),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: isDownloading
                                  ? null
                                  : () async {
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);

                                      final success = await docProvider
                                          .downloadFile(
                                            'https://ovacs.com/backend${document.secureDownloadUrl}',
                                            document.fileName,
                                            document.id,
                                          );

                                      if (mounted) {
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? l10n.downloadComplete
                                                  : l10n.downloadFailed,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              icon: isDownloading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Iconsax.arrow_circle_down),
                              label: Text(l10n.download),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get helper text for security level dropdown
  String _getSecurityLevelHelperText(UserRole userRole) {
    switch (userRole) {
      case UserRole.silver:
        return 'Silver users can only edit Green (General) documents';
      case UserRole.gold:
        return 'Gold users can edit Yellow (Confidential) and Green (General) documents';
      case UserRole.diamond:
      case UserRole.admin:
      case UserRole.owner:
        return 'You can edit documents with any security level';
    }
  }

  void _showEditDialog(
    BuildContext context,
    DocumentModel document,
    DocumentDetailProvider provider,
  ) {
    String selectedLevel = document.securityLevel;
    final l10n = AppLocalizations.of(context)!;

    // Get allowed security levels for current user role
    final userRole = currentUserRole;
    final allowedLevels = PermissionConfig.getCreatableDocumentLevels(userRole);
    final allowedLevelStrings = allowedLevels
        .map((level) => level.value)
        .toList();

    // If current document security level is not in allowed levels, user can't edit it
    if (!allowedLevelStrings.contains(selectedLevel)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You do not have permission to edit ${DocumentSecurityLevel.fromString(selectedLevel).displayName} documents.',
          ),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.edit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedLevel,
              items: allowedLevelStrings
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(
                        DocumentSecurityLevel.fromString(level).displayName,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedLevel = value;
                }
              },
              decoration: InputDecoration(
                labelText: l10n.securityLevel,
                helperText: _getSecurityLevelHelperText(userRole),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop();
              final success = await provider.updateDocument(document.id, {
                'security_level': selectedLevel,
              });

              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? l10n.updateSuccessful : l10n.updateFailed,
                    ),
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    DocumentModel document,
    DocumentDetailProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Text(l10n.areYouSureYouWantToDeleteThisDocument),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop();
              final success = await provider.deleteDocument(document.id);

              if (mounted) {
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l10n.deleteSuccessful)),
                  );
                  navigator.pop(); // Go back to previous screen
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l10n.deleteFailed)),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showMoveToGroupDialog(
    BuildContext context,
    DocumentModel document,
    DocumentDetailProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.moveToGroup),
        content: Consumer<GroupsProvider>(
          builder: (context, groupsProvider, child) {
            // Fetch groups when dialog opens
            if (groupsProvider.groups.isEmpty &&
                groupsProvider.status != GroupsStatus.loading) {
              Future.microtask(() {
                if (document.session != null) {
                  groupsProvider.fetchGroupsBySession(document.session!);
                }
              });
            }

            if (groupsProvider.status == GroupsStatus.loading) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (groupsProvider.groups.isEmpty) {
              return SizedBox(
                height: 100,
                child: Center(child: Text(l10n.noGroupsAvailable)),
              );
            }

            return SizedBox(
              width: double.maxFinite,
              height: 200,
              child: ListView.builder(
                itemCount: groupsProvider.groups.length,
                itemBuilder: (context, index) {
                  final group = groupsProvider.groups[index];
                  final isCurrentGroup = document.group == group.id;

                  return ListTile(
                    title: Text(group.name),
                    subtitle: Text(group.description),
                    trailing: isCurrentGroup
                        ? Icon(
                            Iconsax.tick_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: isCurrentGroup
                        ? null
                        : () async {
                            Navigator.pop(context);
                            final success = await provider.moveDocumentToGroup(
                              document.id,
                              group.id,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? l10n.moveSuccessful
                                        : l10n.moveFailed,
                                  ),
                                ),
                              );
                            }
                          },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
