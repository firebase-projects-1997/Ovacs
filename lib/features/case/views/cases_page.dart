import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

import '../../../core/functions/is_dark_mode.dart';
import '../../../data/models/case_model.dart';
import '../../../l10n/app_localizations.dart';
import '../provider/cases_provider.dart';
import '../widgets/case_card.dart';
import 'add_new_case_page.dart';
import 'search_cases_page.dart';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CasesProvider>(context, listen: false).fetchCases();
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        Provider.of<CasesProvider>(context, listen: false).fetchMoreCases();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Provider.of<CasesProvider>(context, listen: false).fetchCases();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Consumer<CasesProvider>(
                  builder: (context, provider, _) {
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
                              onPressed: () => provider.fetchCases(),
                              child: Text(
                                AppLocalizations.of(context)!.retry,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: AppColors.pureWhite),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.cases.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      controller: _scrollController,
                      itemCount:
                          provider.cases.length +
                          (provider.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == provider.cases.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final CaseModel caseItem = provider.cases[index];
                        return CaseCard(caseModel: caseItem);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        RoundedContainer(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SearchCasesPage()),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.allCases,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            RoundedContainer(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddNewCasePage()),
                );
              },

              child: Icon(Iconsax.add, color: isDarkMode(context) ? AppColors.pureWhite :AppColors.charcoalGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Text(
            AppLocalizations.of(context)!.nothingToDisplayHere,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.youMustAddCasesToShowThem,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
