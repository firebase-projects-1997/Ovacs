import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/constants/app_sizes.dart';
import 'package:new_ovacs/core/utils/color_utils.dart';
import 'package:new_ovacs/features/onboarding/views/welcome_page.dart';
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

                  RoundedContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.darkMode,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            themeProvider.toggleTheme();
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                RotationTransition(
                                  turns: animation,
                                  child: child,
                                ),
                            child: Icon(
                              themeProvider.isDarkMode
                                  ? Iconsax.moon
                                  : Iconsax.sun_1,
                              key: ValueKey<bool>(themeProvider.isDarkMode),
                              size: 32,
                              color: themeProvider.isDarkMode
                                  ? Theme.of(context).primaryColor
                                  : Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  RoundedContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.language,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            final newLocale =
                                localeProvider.locale.languageCode == 'en'
                                ? Locale('ar')
                                : Locale('en');
                            localeProvider.setLocale(newLocale);
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Row(
                              key: ValueKey<String>(
                                localeProvider.locale.languageCode,
                              ),
                              children: [
                                Icon(
                                  localeProvider.locale.languageCode == 'en'
                                      ? Iconsax.global
                                      : Iconsax.global,
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localeProvider.locale.languageCode == 'en'
                                      ? AppLocalizations.of(context)!.english
                                      : AppLocalizations.of(context)!.arabic,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  RoundedContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.primaryColor,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ColorUtils.themeColors
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildColorDot(
                                  context,
                                  entry.value,
                                  ColorUtils.themeColorNames[entry.key],
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

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

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                    ),
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      navigatorKey.currentState!.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const WelcomePage(),
                        ),
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

  Widget _buildColorDot(BuildContext context, Color color, String colorName) {
    final themeProvider = context.read<ThemeProvider>();
    final isSelected = themeProvider.primaryColor == color;

    return Tooltip(
      message: colorName,
      child: GestureDetector(
        onTap: () => themeProvider.setPrimaryColor(color),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: isSelected
                ? Border.all(color: Colors.black, width: 3)
                : Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
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
      child: Text.rich(
        overflow: TextOverflow.ellipsis,
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
            ),
            TextSpan(
              text: value ?? '-',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
