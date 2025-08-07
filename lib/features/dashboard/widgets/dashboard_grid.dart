import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../common/providers/theme_provider.dart';
import '../../../data/models/dashboard_summary_model.dart';
import '../../../l10n/app_localizations.dart';

class DashboardGrid extends StatelessWidget {
  final DashboardSummaryModel data;

  const DashboardGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        'title': AppLocalizations.of(context)!.totalCases,
        'value': data.totalCases.toString(),
        'icon': Iconsax.document_normal,
      },
      {
        'title': AppLocalizations.of(context)!.totalClients,
        'value': data.totalClients.toString(),
        'icon': Iconsax.link,
      },
      {
        'title': AppLocalizations.of(context)!.totalDocuments,
        'value': data.totalDocuments.toString(),
        'icon': Iconsax.document,
      },
      {
        'title': AppLocalizations.of(context)!.totalSpaceUsed,
        'value': '${data.spaceUsedPercentage}%',
        'icon': Iconsax.chart_square,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: cards.length,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => _DashboardCard(
          title: cards[index]['title'] as String,
          value: cards[index]['value'] as String,
          iconData: cards[index]['icon'] as IconData,
          index: index,
          dashboardColors: themeProvider.dashboardColors,
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData iconData;
  final int index;
  final List<Color> dashboardColors;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.iconData,
    required this.index,
    required this.dashboardColors,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = dashboardColors[index % dashboardColors.length];
    final Color iconBgColor = bgColor.withValues(alpha: 0.2);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 50, end: 0),
      duration: Duration(milliseconds: 300 + index * 150),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return Opacity(
          opacity: 1 - offset / 50,
          child: Transform.translate(offset: Offset(0, offset), child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              bgColor.withValues(alpha: 0.9),
              bgColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 30, color: AppColors.pureWhite),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.pureWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.pureWhite),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
