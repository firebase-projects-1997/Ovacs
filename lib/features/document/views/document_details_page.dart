import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/document_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/document_detail_provider.dart';
import '../providers/documents_provider.dart';

class DocumentDetailsPage extends StatefulWidget {
  final int documentId;

  const DocumentDetailsPage({super.key, required this.documentId});

  @override
  State<DocumentDetailsPage> createState() => _DocumentDetailsPageState();
}

class _DocumentDetailsPageState extends State<DocumentDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<DocumentDetailProvider>().fetchDocumentDetail(
          widget.documentId,
        );
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
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, provider.document!, provider);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, provider.document!, provider);
                  }
                },
                itemBuilder: (context) => [
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
                ],
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<DocumentsProvider>(
                        builder: (context, docProvider, child) {
                          final isDownloading = docProvider
                              .isDocumentDownloading(document.id);

                          return ElevatedButton.icon(
                            onPressed: isDownloading
                                ? null
                                : () async {
                                    final success = await docProvider.downloadFile(
                                      'https://ovacs.com/backend${document.secureDownloadUrl}',
                                      document.fileName,
                                      document.id,
                                    );

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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

  void _showEditDialog(
    BuildContext context,
    DocumentModel document,
    DocumentDetailProvider provider,
  ) {
    String selectedLevel = document.securityLevel;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.edit),
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
          decoration: InputDecoration(labelText: l10n.securityLevel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.updateDocument(document.id, {
                'security_level': selectedLevel,
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
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
              Navigator.pop(context);
              final success = await provider.deleteDocument(document.id);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.deleteSuccessful)),
                  );
                  Navigator.pop(context); // Go back to previous screen
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
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
}
