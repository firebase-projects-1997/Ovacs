import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/permission_resource.dart';
import '../../../core/enums/permission_action.dart';
import '../../../core/functions/is_dark_mode.dart';
import '../../../core/mixins/permission_mixin.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../providers/documents_provider.dart';
import '../providers/group_details_provider.dart';
import '../widgets/document_card.dart';
import 'upload_documents_page.dart';

class GroupDetailsPage extends StatefulWidget {
  final int groupId;
  final int sessionId;
  final int? spaceId;

  const GroupDetailsPage({
    super.key,
    required this.groupId,
    required this.sessionId,
    this.spaceId,
  });

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage>
    with PermissionMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;

      // Load permissions for specific space context if provided
      await loadPermissionsForContext(
        spaceId: widget.spaceId,
        forceRefresh: true,
      );

      if (!mounted) return;

      context.read<GroupDetailsProvider>().fetchGroupDetail(widget.groupId);
      context.read<DocumentsProvider>().fetchDocumentsBySession(
        extraParams: {'session_id': widget.sessionId, 'group': widget.groupId},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupDetailsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.group != null
              ? '${provider.group!.name} Group'
              : 'Group Details',
        ),
      ),
      body: SingleChildScrollView(
        child: switch (provider.status) {
          GroupDetailsStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          GroupDetailsStatus.error => Center(
            child: Text(provider.failure?.message ?? 'Error'),
          ),
          GroupDetailsStatus.loaded => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RoundedContainer(
                  child: Text(
                    provider.group!.description,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.documents,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // Only show add document button if user has create permission
                    if (hasPermissionWithOwnership(
                      PermissionResource.document,
                      PermissionAction.create,
                    ))
                      RoundedContainer(
                        onTap: () {
                          navigatorKey.currentState!.push(
                            MaterialPageRoute(
                              builder: (context) => UploadDocumentsPage(
                                id: widget.sessionId,
                                groupId: provider.group!.id,
                                groupName: provider.group!.name,
                                groupDescription: provider.group!.description,
                              ),
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
                SizedBox(height: 10),
                Consumer<DocumentsProvider>(
                  builder: (context, value, child) {
                    if (value.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (value.errorMessage != null) {
                      return Center(child: Text(value.errorMessage ?? ''));
                    } else if (value.documents.isEmpty) {
                      _buildEmptyState();
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          value.documents.length +
                          (value.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == value.documents.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final document = value.documents[index];
                        return DocumentCard(document: document);
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                    );
                  },
                ),
              ],
            ),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Text(
          AppLocalizations.of(context)!.nothingToDisplayHere,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.youMustAddDocumentsToShowThem,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
