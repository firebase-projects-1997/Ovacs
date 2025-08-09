import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../core/enums/permission_resource.dart';
import '../../../core/enums/permission_action.dart';
import '../../../core/enums/document_security_level.dart';
import '../../../common/widgets/permission_guard.dart';
import '../../../core/mixins/permission_mixin.dart';
import '../../../features/document/providers/documents_provider.dart';
import '../../../data/models/document_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/providers/workspace_provider.dart';
import '../providers/document_detail_provider.dart';
import '../providers/groups_provider.dart';
import '../views/document_details_page.dart';

class DocumentCard extends StatefulWidget {
  final DocumentModel document;

  const DocumentCard({super.key, required this.document});

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> with PermissionMixin {
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
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DocumentsProvider>();
    final locale = AppLocalizations.of(context)!;

    return RoundedContainer(
      onTap: () {
        final workspaceProvider = context.read<WorkspaceProvider>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentDetailsPage(
              documentId: widget.document.id,
              spaceId: workspaceProvider.currentSpaceId,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File Name
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '${locale.fileName}: ',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                    children: [
                      TextSpan(
                        text: widget.document.fileName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await executeWithPermissionInSpaceContext(
                      PermissionResource.document,
                      PermissionAction.update,
                      () async =>
                          _showEditDialog(context, widget.document, provider),
                    );
                  } else if (value == 'delete') {
                    await executeWithPermissionInSpaceContext(
                      PermissionResource.document,
                      PermissionAction.delete,
                      () async =>
                          _showDeleteDialog(context, widget.document, provider),
                    );
                  } else if (value == 'move') {
                    await executeWithPermissionInSpaceContext(
                      PermissionResource.documentGroup,
                      PermissionAction.update,
                      () async =>
                          _showMoveToGroupDialog(context, widget.document),
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
                          Text(locale.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'move',
                      child: Row(
                        children: [
                          const Icon(Iconsax.folder_2),
                          const SizedBox(width: 8),
                          Text(locale.moveToGroup),
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
                            locale.delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                icon: const Icon(Iconsax.more_circle),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Group (if available)
          if (widget.document.groupName != null) ...[
            Text.rich(
              TextSpan(
                text: '${locale.groupName}: ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
                children: [
                  TextSpan(
                    text: widget.document.groupName!,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Created At
          Text.rich(
            TextSpan(
              text: '${locale.createdAt}: ',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
              children: [
                TextSpan(
                  text: _formatDate(widget.document.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // File Size & Actions
          Row(
            children: [
              Text(
                _formatFileSize(widget.document.fileSize),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: AppColors.mediumGrey),
              ),
              SizedBox(width: 10),
              Text(
                "(${widget.document.securityLevel})",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: widget.document.securityLevel == "red"
                      ? AppColors.red
                      : widget.document.securityLevel == 'yellow'
                      ? AppColors.gold
                      : AppColors.green,
                ),
              ),
              const Spacer(),
              // View button with security-level guard
              DocumentSecurityGuard(
                action: PermissionAction.read,
                securityLevel: DocumentSecurityLevel.fromString(
                  widget.document.securityLevel,
                ),
                child: IconButton(
                  icon: const Icon(Iconsax.eye),
                  tooltip: AppLocalizations.of(context)!.view,
                  onPressed: () {
                    provider.viewFile(
                      'https://ovacs.com/backend${widget.document.secureViewUrl}',
                      widget.document.fileName,
                    );
                  },
                ),
                fallback: IconButton(
                  icon: const Icon(Iconsax.eye),
                  tooltip: AppLocalizations.of(context)!.view,
                  onPressed: () {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You don't have permission to view this document",
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Download button with security-level guard
              DocumentSecurityGuard(
                action: PermissionAction.read,
                securityLevel: DocumentSecurityLevel.fromString(
                  widget.document.securityLevel,
                ),
                child: IconButton(
                  icon: provider.isDocumentDownloading(widget.document.id)
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Iconsax.arrow_circle_down),
                  tooltip: AppLocalizations.of(context)!.download,
                  onPressed: provider.isDocumentDownloading(widget.document.id)
                      ? null
                      : () async {
                          final success = await provider.downloadFile(
                            'https://ovacs.com/backend${widget.document.secureDownloadUrl}',
                            widget.document.fileName,
                            widget.document.id, // ✅ Pass document ID
                          );

                          final message = success
                              ? "Download complete"
                              : provider.downloadViewErrorMessage ??
                                    "Download failed";

                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }
                        },
                ),
                fallback: IconButton(
                  icon: const Icon(Iconsax.arrow_circle_down),
                  tooltip: AppLocalizations.of(context)!.download,
                  onPressed: () {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You don't have permission to download this document",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    DocumentModel document,
    DocumentsProvider provider,
  ) {
    String selectedLevel = document.securityLevel;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.edit),
        content: DropdownButtonFormField<String>(
          value: selectedLevel,
          items: ['green', 'yellow', 'red']
              .map(
                (level) => DropdownMenuItem(
                  value: level,
                  child: Text(level[0].toUpperCase() + level.substring(1)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              selectedLevel = value;
            }
          },
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.securityLevel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.updateDocument(document.id, {
                'security_level': selectedLevel,
                'client': document.client,
                "case_id": document.caseId,
                "session_id": document.session,
              });
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    DocumentModel document,
    DocumentsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDeletion),
        content: Text(
          AppLocalizations.of(context)!.areYouSureYouWantToDeleteThisDocument,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteDocument(document.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _showMoveToGroupDialog(BuildContext context, DocumentModel document) {
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

                            // Use DocumentDetailProvider to move the document
                            final detailProvider = context
                                .read<DocumentDetailProvider>();
                            final success = await detailProvider
                                .moveDocumentToGroup(document.id, group.id);

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

                              // Refresh the documents list if successful
                              if (success && document.session != null) {
                                context
                                    .read<DocumentsProvider>()
                                    .fetchDocumentsBySession(
                                      extraParams: {
                                        'session_id': document.session,
                                      },
                                    );
                              }
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
