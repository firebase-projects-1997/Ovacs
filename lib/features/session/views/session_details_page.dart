import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/constants/app_sizes.dart';
import 'package:new_ovacs/features/document/providers/documents_provider.dart';
import 'package:new_ovacs/features/session/providers/session_details_provider.dart';
import 'package:new_ovacs/features/session/views/edit_session_page.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../document/views/groups_page.dart';
import '../../document/views/upload_documents_page.dart';
import '../../document/widgets/document_card.dart';
import '../../session/providers/sessions_provider.dart';
import '../../../l10n/app_localizations.dart';

class SessionDetailsPage extends StatefulWidget {
  final int sessionId;
  final int caseId;
  const SessionDetailsPage({
    super.key,
    required this.sessionId,
    required this.caseId,
  });

  @override
  State<SessionDetailsPage> createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends State<SessionDetailsPage> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SessionDetailProvider>().fetchSessionDetails(
        widget.sessionId,
      );
      context.read<DocumentsProvider>().fetchDocumentsBySession(
        extraParams: {'session_id': widget.sessionId},
      );
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Consumer<SessionDetailProvider>(
          builder: (context, value, _) {
            return Text(
              AppLocalizations.of(
                context,
              )!.sessionInformation(widget.sessionId),
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
                  await navigatorKey.currentState!.push<bool>(
                    MaterialPageRoute(
                      builder: (_) => EditSessionPage(
                        sessionModel: context
                            .read<SessionDetailProvider>()
                            .sessionModel!,
                        caseId: widget.caseId,
                      ),
                    ),
                  );

                  break;
                case 'delete':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        AppLocalizations.of(context)!.confirmDeletion,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: AppColors.titleText,
                        ),
                      ),
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.areYouSureYouWantToDeleteThisSession,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.titleText,
                        ),
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
                        .read<SessionDetailProvider>()
                        .deleteSession(widget.sessionId);
                    if (success) {
                      context.read<SessionsProvider>().fetchSessions(
                        widget.caseId,
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context
                                    .read<SessionDetailProvider>()
                                    .errorMessage ??
                                AppLocalizations.of(
                                  context,
                                )!.errorDeletingSession,
                          ),
                        ),
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
      body: Consumer<SessionDetailProvider>(
        builder: (context, value, _) {
          if (value.status == SessionDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (value.errorMessage != null) {
            return Center(child: Text(value.errorMessage ?? ''));
          } else {
            if (value.sessionModel == null) return SizedBox.shrink();
            return SingleChildScrollView(
              padding: AppSizes.noAppBarPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.session} ${value.sessionModel?.id}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  RoundedContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoColumn(
                          label: AppLocalizations.of(context)!.sessionTitle,
                          value: value.sessionModel?.title ?? '',
                        ),
                        const SizedBox(height: 16),
                        _InfoColumn(
                          label: AppLocalizations.of(context)!.description,
                          value: value.sessionModel?.description ?? '',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoColumn(
                                label: AppLocalizations.of(context)!.time,
                                value:
                                    value.sessionModel?.date
                                        ?.toIso8601String()
                                        .split('T')
                                        .last
                                        .split(".000Z")
                                        .first ??
                                    '',
                                isLink: true,
                              ),
                            ),
                            Expanded(
                              child: _InfoColumn(
                                label: AppLocalizations.of(
                                  context,
                                )!.appearInCourtOn,
                                value:
                                    value.sessionModel?.date
                                        ?.toIso8601String()
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
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      navigatorKey.currentState!.push(
                        MaterialPageRoute(
                          builder: (context) =>
                              GroupsPage(sessionId: value.sessionModel!.id),
                        ),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.viewGroups),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: AppLocalizations.of(context)!.documents,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      RoundedContainer(
                        onTap: () {
                          navigatorKey.currentState!.push(
                            MaterialPageRoute(
                              builder: (context) => UploadDocumentsPage(
                                id: value.sessionModel!.id,
                              ),
                            ),
                          );
                        },
                        child: Icon(Iconsax.add, color: AppColors.charcoalGrey),
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
            );
          }
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
