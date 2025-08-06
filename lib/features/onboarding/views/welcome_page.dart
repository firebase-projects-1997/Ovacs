import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  late List<List<String>> _quotes;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _quotes.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    _quotes = [
      [
        AppLocalizations.of(context)!.weAre,
        AppLocalizations.of(context)!.aLawFirmThatHelps,
        AppLocalizations.of(context)!.tenMillionPlusPeople,
      ],
      [
        AppLocalizations.of(context)!.ourMissionIsTo,
        AppLocalizations.of(context)!.empowerLegalProfessionals,
        AppLocalizations.of(context)!.byProvidingCuttingEdgeSolutions,
      ],
      [
        AppLocalizations.of(context)!.experienceTheFuture,
        AppLocalizations.of(context)!.ofLegalDocumentManagement,
        AppLocalizations.of(context)!.withOurIntuitivePlatform,
      ],
      [
        AppLocalizations.of(context)!.joinUsIn,
        AppLocalizations.of(context)!.revolutionizingLegalArchiving,
        AppLocalizations.of(context)!.whereSpeedMeetsSecurity,
      ],
    ];
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          Padding(
            padding: AppSizes.defaultPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () =>
                          navigatorKey.currentState!.pushNamedAndRemoveUntil(
                            AppRoutes.loginRoute,
                            (route) => false,
                          ),
                      icon: Text(
                        AppLocalizations.of(context)!.skip,
                        style: textTheme.bodySmall!.copyWith(
                          color: AppColors.pureWhite,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  AppImages.logo,
                  width: MediaQuery.of(context).size.width * .5,
                ),
                RoundedContainer(
                  backgroundColor: AppColors.pureWhite.withValues(alpha: .3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      RoundedContainer(
                        backgroundColor: AppColors.primaryBlue.withValues(
                          alpha: .2,
                        ),
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.towardsWorldOfSpeedInArchiving,
                          style: textTheme.titleLarge!.copyWith(
                            color: AppColors.pureWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * .15,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _quotes.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _quotes[index][0],
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _quotes[index][1],
                                  style: textTheme.titleLarge!.copyWith(
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Expanded(
                                  child: Text(
                                    _quotes[index][2],
                                    style: textTheme.bodySmall!.copyWith(
                                      color: AppColors.pureWhite,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          _quotes.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.pureWhite),
                              color: index == _currentPage
                                  ? AppColors.pureWhite
                                  : Colors.transparent,
                            ),
                            width: 8,
                            height: 8,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: SvgPicture.asset(AppImages.facebook),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: SvgPicture.asset(AppImages.x),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: SvgPicture.asset(AppImages.linkedin),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: SvgPicture.asset(AppImages.instagram),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
