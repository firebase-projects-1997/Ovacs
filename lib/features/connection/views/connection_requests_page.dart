import 'package:flutter/material.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/constants/app_sizes.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/received_requests_provider.dart';
import '../providers/sent_requests_provider.dart';

class ConnectionRequestsPage extends StatefulWidget {
  const ConnectionRequestsPage({super.key});

  @override
  State<ConnectionRequestsPage> createState() => _ConnectionRequestsPageState();
}

class _ConnectionRequestsPageState extends State<ConnectionRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      Provider.of<ReceivedRequestsProvider>(
        context,
        listen: false,
      ).fetchReceivedRequests();
      Provider.of<SentRequestsProvider>(
        context,
        listen: false,
      ).fetchSentRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.connectionRequests),
        bottom: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          controller: _tabController,
          tabs: [
            Tab(text: l10n.received),
            Tab(text: l10n.sent),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer<ReceivedRequestsProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.failure != null) {
                return Center(child: Text(provider.failure!.message));
              }
              return ListView.separated(
                padding: AppSizes.noAppBarPadding(context),
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemCount: provider.receivedRequests.length,
                itemBuilder: (context, index) {
                  return RoundedContainer(
                    child: ListTile(
                      key: ValueKey(provider.receivedRequests[index].id),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        provider.receivedRequests[index].receiverName,
                      ),
                      subtitle: Text(
                        l10n.idWithValue(
                          provider.receivedRequests[index].id.toString(),
                        ),
                      ),
                      trailing:
                          provider.loadingIds.contains(
                            provider.receivedRequests[index].id,
                          )
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SizedBox(
                              width: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.green,
                                    ),
                                    onPressed: () async {
                                      final isSuccess = await provider
                                          .respondRequest(
                                            index,
                                            RequestType.accept,
                                          );
                                      if (!mounted) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isSuccess
                                                ? l10n.connectionRequestSentSuccess
                                                : l10n.connectionRequestSentFailure(
                                                    provider
                                                            .sendRequestfailure
                                                            ?.message ??
                                                        l10n.somethingWentWrong,
                                                  ),
                                          ),
                                          backgroundColor: isSuccess
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      );

                                      if (isSuccess) {
                                        context
                                            .read<ReceivedRequestsProvider>()
                                            .fetchReceivedRequests();
                                      }
                                    },
                                    child: Text(l10n.accept),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.red,
                                    ),
                                    onPressed: () async {
                                      final isSuccess = await provider
                                          .respondRequest(
                                            index,
                                            RequestType.reject,
                                          );
                                      if (!mounted) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isSuccess
                                                ? l10n.connectionRequestSentSuccess
                                                : l10n.connectionRequestSentFailure(
                                                    provider
                                                            .sendRequestfailure
                                                            ?.message ??
                                                        l10n.somethingWentWrong,
                                                  ),
                                          ),
                                          backgroundColor: isSuccess
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      );

                                      if (isSuccess) {
                                        context
                                            .read<ReceivedRequestsProvider>()
                                            .fetchReceivedRequests();
                                      }
                                    },
                                    child: Text(l10n.reject),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          ),

          Consumer<SentRequestsProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.failure != null) {
                return Center(child: Text(provider.failure!.message));
              }
              return ListView.separated(
                padding: AppSizes.noAppBarPadding(context),
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemCount: provider.sentRequests.length,
                itemBuilder: (context, index) {
                  return RoundedContainer(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(provider.sentRequests[index].senderName),
                      subtitle: Text(
                        l10n.idWithValue(
                          provider.sentRequests[index].id.toString(),
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: null,
                        child: Text(l10n.pending),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
