import 'package:flutter/material.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/case_model.dart';
import '../../../l10n/app_localizations.dart';
import '../views/case_details_page.dart';

class CaseCard extends StatelessWidget {
  final CaseModel caseModel;

  const CaseCard({super.key, required this.caseModel});

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaseDetailsPage(caseId: caseModel.id),
          ),
        );
      },
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text.rich(
                  overflow: TextOverflow.ellipsis,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.caseName,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      TextSpan(
                        text: caseModel.title,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.date,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                    TextSpan(
                      text: caseModel.date.toIso8601String().split("T").first,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.clientName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
                ),
                TextSpan(
                  text: caseModel.clientName,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.primaryBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
                ),
                TextSpan(
                  text: caseModel.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 5,
            children: [
              Text(
                AppLocalizations.of(context)!.lawyers,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
              ),

              if (caseModel.assignedAccountNames != null &&
                  caseModel.assignedAccountNames!.isNotEmpty)
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: caseModel.assignedAccountNames!
                      .map(
                        (lawyer) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryBlue,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            lawyer,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                      .toList(),
                )
              else
                Text(
                  AppLocalizations.of(context)!.nA,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
