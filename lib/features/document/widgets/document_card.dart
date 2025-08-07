import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../features/document/providers/documents_provider.dart';
import '../../../data/models/document_model.dart';
import '../../../l10n/app_localizations.dart';
import '../views/document_details_page.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;

  const DocumentCard({super.key, required this.document});

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentDetailsPage(documentId: document.id),
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
                        text: document.fileName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, document, provider);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, document, provider);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text(locale.edit)),
                  PopupMenuItem(value: 'delete', child: Text(locale.delete)),
                ],
                icon: const Icon(Iconsax.more_circle),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Group (if available)
          if (document.groupName != null) ...[
            Text.rich(
              TextSpan(
                text: '${locale.groupName}: ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
                children: [
                  TextSpan(
                    text: document.groupName!,
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
                  text: _formatDate(document.createdAt),
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
                _formatFileSize(document.fileSize),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: AppColors.mediumGrey),
              ),
              SizedBox(width: 10),
              Text(
                "(${document.securityLevel})",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: document.securityLevel == "red"
                      ? AppColors.red
                      : document.securityLevel == 'yellow'
                      ? AppColors.gold
                      : AppColors.green,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Iconsax.eye),
                tooltip: AppLocalizations.of(context)!.view,
                onPressed: () {
                  provider.viewFile(
                    'https://ovacs.com/backend${document.secureViewUrl}',
                    document.fileName,
                  );
                },
              ),
              IconButton(
                icon: provider.isDocumentDownloading(document.id)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Iconsax.arrow_circle_down),
                tooltip: AppLocalizations.of(context)!.download,
                onPressed: provider.isDocumentDownloading(document.id)
                    ? null
                    : () async {
                        final success = await provider.downloadFile(
                          'https://ovacs.com/backend${document.secureViewUrl}',
                          document.fileName,
                          document.id, // ✅ Pass document ID
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
}
