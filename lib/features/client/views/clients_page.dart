import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/common/widgets/permission_guard.dart';
import 'package:new_ovacs/core/enums/permission_resource.dart';
import 'package:new_ovacs/core/enums/permission_action.dart';
import 'package:new_ovacs/features/case/views/add_new_case_page.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../core/functions/is_dark_mode.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../providers/clients_provider.dart';
import '../widgets/client_card.dart';
import 'search_clients_page.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ClientsProvider>(context, listen: false).fetchClients();
      }
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        Provider.of<ClientsProvider>(context, listen: false).fetchMoreClients();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Provider.of<ClientsProvider>(context, listen: false).fetchClients();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientsProvider>(context);

    return Scaffold(
      body: Padding(
        padding: AppSizes.defaultPadding(context),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildBody(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ClientsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchClients(),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.clients.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [_buildEmptyState()],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      controller: _scrollController,
      itemCount: provider.clients.length + (provider.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == provider.clients.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final client = provider.clients[index];
        return ClientCard(client: client);
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RoundedContainer(
                onTap: () {
                  navigatorKey.currentState!.push(
                    MaterialPageRoute(
                      builder: (context) => const SearchClientsPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Iconsax.search_normal, color: AppColors.mediumGrey),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.search,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            RoundedContainer(
              onTap: () {
                showAppSnackBar(
                  context,
                  'comming soon',
                  type: SnackBarType.info,
                );
              },
              child: Icon(
                Iconsax.document_upload,
                color: isDarkMode(context)
                    ? AppColors.pureWhite
                    : AppColors.charcoalGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.allClients,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            PermissionGuard(
              resource: PermissionResource.client,
              action: PermissionAction.create,
              child: RoundedContainer(
                onTap: () {
                  navigatorKey.currentState!.push(
                    MaterialPageRoute(
                      builder: (context) => const AddNewCasePage(),
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
      ],
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
          AppLocalizations.of(context)!.youMustAddClientsToShowThem,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
