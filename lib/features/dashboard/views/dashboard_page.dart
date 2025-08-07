import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_ovacs/core/constants/app_images.dart';
import 'package:new_ovacs/core/constants/app_sizes.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../session/views/session_details_page.dart';
import '../../session/widgets/session_card.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/calander_view.dart';
import '../widgets/dashboard_grid.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchAllDashboardData();
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      context.read<DashboardProvider>().loadMoreSessions();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<DashboardProvider>().fetchAllDashboardData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                ? Center(child: Text(provider.errorMessage!))
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: AppSizes.defaultPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SvgPicture.asset(AppImages.logo),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.dashboard,
                          style: Theme.of(context).textTheme.bodyLarge!,
                        ),
                        const SizedBox(height: 20),
                        DashboardGrid(data: provider.summary),

                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.mySchedule,
                          style: Theme.of(context).textTheme.bodyLarge!,
                        ),
                        const SizedBox(height: 10),
                        CalendarView(sessionDates: provider.sessions),

                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.upcomingSessions,
                          style: Theme.of(context).textTheme.bodyLarge!,
                        ),
                        const SizedBox(height: 10),

                        if (provider.sessions.isEmpty)
                          _buildEmptyState()
                        else
                          ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) => SessionCard(
                              onTap: () {
                                navigatorKey.currentState!.push(
                                  MaterialPageRoute(
                                    builder: (context) => SessionDetailsPage(
                                      sessionId: provider.sessions[index].id,
                                      caseId: provider.sessions[index].caseId!,
                                    ),
                                  ),
                                );
                              },
                              sessionModel: provider.sessions[index],
                            ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemCount: provider.sessions.length,
                          ),

                        if (provider.isFetchingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.nothingToDisplayHere,
              style: Theme.of(context).textTheme.bodyMedium!,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.youMustAddSessionsToShowThem,
              style: Theme.of(context).textTheme.bodySmall!,
            ),
          ],
        ),
      ),
    );
  }
}
