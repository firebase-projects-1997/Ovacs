import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../data/models/dashboard_summary_model.dart';
import '../../../l10n/app_localizations.dart';

class DashboardGrid extends StatelessWidget {
  final DashboardSummaryModel data;

  const DashboardGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DashboardCard(
        title: AppLocalizations.of(context)!.totalCases,
        value: data.totalCases.toString(),
        iconData: Iconsax.document_normal,
      ),
      _DashboardCard(
        title: AppLocalizations.of(context)!.totalClients,
        value: data.totalClients.toString(),
        iconData: Iconsax.people,
      ),
      _DashboardCard(
        title: AppLocalizations.of(context)!.totalDocuments,
        value: data.totalDocuments.toString(),
        iconData: Iconsax.document,
      ),
      _DashboardCard(
        title: AppLocalizations.of(context)!.totalSpaceUsed,
        value: '${data.spaceUsedPercentage}%',
        iconData: Iconsax.chart_square,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: cards.length,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData iconData;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(iconData),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
