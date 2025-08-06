import 'package:flutter/material.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/constants/app_routes.dart';
import 'package:new_ovacs/core/constants/app_sizes.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';

import '../../../common/providers/locale_provider.dart';
import '../../../common/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSizes.defaultPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.settings,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),

                  // 🌙 Theme Switch
                  RoundedContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.darkMode,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Switch(
                            key: ValueKey<bool>(themeProvider.isDarkMode),
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🌍 Language Dropdown
                  RoundedContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.language,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        DropdownButton<Locale>(
                          value: localeProvider.locale,
                          onChanged: (locale) {
                            if (locale != null) {
                              localeProvider.setLocale(locale);
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Text(
                                AppLocalizations.of(context)!.english,
                              ),
                            ),
                            DropdownMenuItem(
                              value: Locale('ar'),
                              child: Text(AppLocalizations.of(context)!.arabic),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 👤 Account Info
                  RoundedContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          AppLocalizations.of(context)!.accountInformation,
                        ),
                        const SizedBox(height: 8),
                        ProfileInfoRow(
                          label: AppLocalizations.of(context)!.name,
                          value: user.name ?? '-',
                        ),
                        ProfileInfoRow(
                          label: AppLocalizations.of(context)!.email,
                          value: user.email ?? '-',
                        ),
                        ProfileInfoRow(
                          label: AppLocalizations.of(context)!.mobile,
                          value: user.mobile ?? '-',
                        ),
                        ProfileInfoRow(
                          label: AppLocalizations.of(context)!.role,
                          value: user.role ?? '-',
                        ),
                        ProfileInfoRow(
                          label: AppLocalizations.of(context)!.country,
                          value: user.country?.name ?? '-',
                        ),
                        const Divider(),
                        SectionTitle(
                          AppLocalizations.of(context)!.companyInformation,
                        ),
                        const SizedBox(height: 8),
                        ProfileInfoRow(
                          label: AppLocalizations.of(context)!.companyName,
                          value: user.account?.name ?? '-',
                        ),
                        ProfileInfoRow(
                          label: AppLocalizations.of(context)!.active,
                          value: user.account?.isActive == true
                              ? AppLocalizations.of(context)!.yes
                              : AppLocalizations.of(context)!.no,
                        ),
                        ProfileInfoRow(
                          label: AppLocalizations.of(context)!.createdAt,
                          value: formatDate(user.account?.createdAt),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🚪 Logout
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                    ),
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      navigatorKey.currentState!.pushNamedAndRemoveUntil(
                        AppRoutes.loginRoute,
                        (route) => false,
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.logout),
                  ),
                ],
              ),
            ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const ProfileInfoRow({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
