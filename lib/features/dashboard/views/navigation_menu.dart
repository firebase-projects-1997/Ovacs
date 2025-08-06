import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_images.dart';
import '../../../l10n/app_localizations.dart';
import '../../case/views/cases_page.dart';
import '../../client/views/clients_page.dart';
import '../../connection/views/connections_page.dart';
import '../../settings/views/settings_page.dart';
import 'dashboard_page.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int index = 0;

  final List<Widget> pages = [
    DashboardPage(),
    CasesPage(),
    ConnectionsPage(),
    ClientsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navigationMenuList = [
      {'icon': AppImages.home, 'name': AppLocalizations.of(context)!.home},
      {'icon': AppImages.cases, 'name': AppLocalizations.of(context)!.cases},
      {
        'icon': AppImages.connections,
        'name': AppLocalizations.of(context)!.connections,
      },
      {
        'icon': AppImages.clients,
        'name': AppLocalizations.of(context)!.clients,
      },
      {
        'icon': AppImages.settings,
        'name': AppLocalizations.of(context)!.settings,
      },
    ];
    final theme = Theme.of(context);

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
          color:
              theme.bottomNavigationBarTheme.backgroundColor ??
              theme.scaffoldBackgroundColor,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(navigationMenuList.length, (i) {
            final single = navigationMenuList[i];
            final bool isSelected = i == index;
            final Color selectedColor = isSelected
                ? theme.colorScheme.primary
                : theme.iconTheme.color!;
            final Color textColor = isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodySmall!.color!;

            return GestureDetector(
              onTap: () {
                setState(() {
                  index = i;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    SvgPicture.asset(single['icon'], color: selectedColor),
                    const SizedBox(height: 4),
                    Text(
                      single['name'],
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
