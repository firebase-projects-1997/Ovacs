import 'package:flutter/material.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../data/models/session_model.dart';
import '../../../l10n/app_localizations.dart';

class SessionCard extends StatelessWidget {
  final SessionModel sessionModel;
  final void Function()? onTap;

  const SessionCard({super.key, required this.sessionModel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      onTap: onTap,
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.sessionName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
                ),
                TextSpan(
                  text: sessionModel.title ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Text.rich(
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
                ),
                TextSpan(
                  text: sessionModel.description ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Row(
            children: [
              Expanded(
                child: Text.rich(
                  overflow: TextOverflow.ellipsis,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.time,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      TextSpan(
                        text:
                            sessionModel.date
                                ?.toIso8601String()
                                .split('T')
                                .last
                                .split('.000Z')
                                .first ??
                            AppLocalizations.of(context)!.noTimeAdded,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Text.rich(
                  overflow: TextOverflow.ellipsis,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.date,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      TextSpan(
                        text:
                            sessionModel.date
                                ?.toIso8601String()
                                .split('T')
                                .first ??
                            '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
