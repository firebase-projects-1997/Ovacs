import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; // تأكد من إضافته في pubspec.yaml

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
      {'icon': Iconsax.element_4, 'name': AppLocalizations.of(context)!.home},
      {
        'icon': Iconsax.document_text,
        'name': AppLocalizations.of(context)!.cases,
      },
      {'icon': Iconsax.link, 'name': AppLocalizations.of(context)!.connections},
      {
        'icon': Iconsax.profile_2user,
        'name': AppLocalizations.of(context)!.clients,
      },
      {'icon': Iconsax.setting, 'name': AppLocalizations.of(context)!.settings},
    ];

    final theme = Theme.of(context);

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: theme.dividerColor.withAlpha(50)),
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

                    AnimatedScale(
                      scale: isSelected ? 1.3 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: Icon(single['icon'], color: selectedColor),
                    ),

                    const SizedBox(height: 10),

                    AnimatedDefaultTextStyle(
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: textColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      duration: const Duration(milliseconds: 300),
                      child: Text(single['name']),
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
